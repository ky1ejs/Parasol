//
//  XcodeProject.swift
//  Parasol
//
//  Created by Kyle McAlpine on 31/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation
import Xcode

struct XcodeBuild {
    static func buildSettingsForXcodeProject(projectPath: String, schemeName: String?) -> String? {
        let task = NSTask()
        task.launchPath = "/usr/bin/xcodebuild" // TODO: make optional argument
        var arguments = ["-project", projectPath]
        if let scheme = schemeName {
            arguments += ["-scheme", scheme]
        }
        arguments.append("-showBuildSettings")
        task.arguments = arguments
        let outputPipe = NSPipe()
        task.standardOutput = outputPipe
        task.launch()
        task.waitUntilExit()
        return String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
    }
}

struct XcodeProject {
    static let fileManager = NSFileManager()
    
    let url: NSURL
    let name: String
    var projectFile: XCProjectFile { return try! XCProjectFile(xcodeprojURL: self.url) }
    
    init?(url: NSURL) {
        var projectName: String?
        let regex = try! NSRegularExpression(pattern: "^\\s*PROJECT_NAME = ", options: [])
        XcodeBuild.buildSettingsForXcodeProject(url.absoluteString, schemeName: nil)?.enumerateLines { (line, stop) -> () in
            let mutableLine = NSMutableString(string: line)
            if regex.replaceMatchesInString(mutableLine as NSMutableString, options: [], range: NSMakeRange(0, mutableLine.length), withTemplate: "") == 1 {
                projectName = mutableLine as String
                stop = true
            }
        }
        if let projectName = projectName {
            self.url = url
            self.name = projectName
            return
        }
        return nil
    }
    
    var targets: [Target] {
        var targets = [Target]()
        for target in self.projectFile.project.targets {
            targets.append(Target(project: self, targetFile: target))
        }
        return targets
    }
    
    var buildSettings: String? {
        return XcodeBuild.buildSettingsForXcodeProject(self.url.lastPathComponent!, schemeName: nil)
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
    
    static func findXcodeProjectInCurrentDirectory() -> XcodeProject? {
        var xcodeProject: XcodeProject?
        let files = try! self.fileManager.contentsOfDirectoryAtPath(fileManager.currentDirectoryPath)
        for file in files {
            if let url = NSURL(string: file), foundProject = XcodeProject(url: url) {
                xcodeProject = foundProject
                break
            }
        }
        return xcodeProject
    }
}

struct Target {
    var name: String { return self.targetFile.name }
    var project: XcodeProject
    let targetFile: PBXTarget
    
    var buildSettings: String? {
        return XcodeBuild.buildSettingsForXcodeProject(self.project.url.lastPathComponent!, schemeName: self.name)
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
    
    var codeCoverageDir: String? {
        var codeCoverageDir: String?
        if let tempRoot = self.project.tempRoot {
            codeCoverageDir = tempRoot + "/CodeCoverage/\(self.project.name)"
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
