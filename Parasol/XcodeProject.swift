//
//  XcodeProject.swift
//  Parasol
//
//  Created by Kyle McAlpine on 31/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation
import Xcode

struct XcodeProject {
    let url: NSURL
    var name: String { return self.url.lastPathComponent! }
    var projectFile: XCProjectFile { return try! XCProjectFile(xcodeprojURL: self.url) }
    
    init?(url: NSURL) {
        if let fileExtension = url.pathExtension where fileExtension == "xcodeproj" {
            self.url = url
            return
        }
        return nil
    }
    
    static func findXcodeProjectInCurrentDirectory() -> XcodeProject? {
        var xcodeProject: XcodeProject?
        let fileManager = NSFileManager.defaultManager()
        let files = try! fileManager.contentsOfDirectoryAtPath(fileManager.currentDirectoryPath)
        for file in files {
            if let url = NSURL(string: file), foundProject = XcodeProject(url: url) {
                xcodeProject = foundProject
                break
            }
        }
        return xcodeProject
    }
    
    var buildSettings: String? {
        let task = NSTask()
        task.launchPath = "/usr/bin/xcodebuild" // TODO: make optional argument
        task.arguments = ["-project", self.name, "-scheme", "Parasol", "-showBuildSettings"]
        let outputPipe = NSPipe()
        task.standardOutput = outputPipe
        task.launch()
        task.waitUntilExit()
        return String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
    }
    
    var tempRoot: String? {
        var tempDirPath: String?
        let regex = try! NSRegularExpression(pattern: "^\\s*TEMP_ROOT = ", options: [])
        self.buildSettings?.enumerateLines({ (line, stop) -> () in
            let mutableLine = NSMutableString(string: line)
            if regex.replaceMatchesInString(mutableLine as NSMutableString, options: [], range: NSMakeRange(0, mutableLine.length), withTemplate: "") == 1 {
                tempDirPath = mutableLine as String
                stop = true
            }
        })
        return tempDirPath
    }
    
    var executablePath: String? {
        var executablePath: String?
        let regex = try! NSRegularExpression(pattern: "^\\s*EXECUTABLE_PATH = ", options: [])
        self.buildSettings?.enumerateLines({ (line, stop) -> () in
            let mutableLine = NSMutableString(string: line)
            if regex.replaceMatchesInString(mutableLine as NSMutableString, options: [], range: NSMakeRange(0, mutableLine.length), withTemplate: "") == 1 {
                executablePath = mutableLine as String
                stop = true
            }
        })
        return executablePath
    }
    
    var projectName: String? {
        var projectName: String?
        let regex = try! NSRegularExpression(pattern: "^\\s*PROJECT_NAME = ", options: [])
        self.buildSettings?.enumerateLines({ (line, stop) -> () in
            let mutableLine = NSMutableString(string: line)
            if regex.replaceMatchesInString(mutableLine as NSMutableString, options: [], range: NSMakeRange(0, mutableLine.length), withTemplate: "") == 1 {
                projectName = mutableLine as String
                stop = true
            }
        })
        return projectName
    }
    
    var codeCoverageDir: String? {
        var codeCoverageDir: String?
        if let tempRoot = self.tempRoot, projectName = self.projectName {
            codeCoverageDir = tempRoot + "/CodeCoverage/\(projectName)"
        }
        return codeCoverageDir
    }
    
    var codeCoverageProfdataPath: String? {
        var coverageProfdataPath: String?
        if let codeCoverageDir = self.codeCoverageDir {
            coverageProfdataPath = codeCoverageDir + "/Coverage.profdata"
        }
        return coverageProfdataPath
    }
    
    var codeCoverageExecutablePath: String? {
        var codeCoverageExecutablePath: String?
        if let codeCoverageDir = self.codeCoverageDir, executablePath = self.executablePath {
            codeCoverageExecutablePath = codeCoverageDir + "/Products/Debug/\(executablePath)"
        }
        return codeCoverageExecutablePath
    }
    
    enum CoverageDataExistence {
        case Exists(profdataPath: String, executablePath: String)
        case DoesNotExists
    }
    
    var coverageDataExists: CoverageDataExistence {
        let fileManager = NSFileManager.defaultManager()
        if let profdataPath = self.codeCoverageProfdataPath, executablePath = self.codeCoverageExecutablePath
            where fileManager.fileExistsAtPath(profdataPath) && fileManager.fileExistsAtPath(executablePath) {
                return .Exists(profdataPath: profdataPath, executablePath: executablePath)
        }
        return .DoesNotExists
    }
    
    func runTests() {
        let task = NSTask()
        task.launchPath = "/usr/bin/xcodebuild"
        task.arguments = ["test", "-project", self.name, "-scheme", "Parasol", "-enableCodeCoverage", "YES"]
        task.standardOutput = NSPipe()
        task.launch()
        print("testing...")
        task.waitUntilExit()
    }
}
