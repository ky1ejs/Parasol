//
//  Target.swift
//  Parasol
//
//  Created by Kyle McAlpine on 09/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation
import Xcode

struct Target {
    var name: String { return self.targetFile.name }
    var project: XcodeProject
    let targetFile: PBXTarget
    
    var buildSettings: String? {
        return XcodeBuild.buildSettingsForXcodeProject(self.project.url.path!, schemeName: self.name)
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
    
    
    // MARK: Code coverage
    var codeCoverageDir: String? {
        var codeCoverageDir: String?
        if let tempRoot = self.project.tempRoot {
            codeCoverageDir = tempRoot + "/CodeCoverage/\(self.name)"
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
            switch self.targetFile.productType {
            case .CommandLineTool:
                codeCoverageExecutablePath = "\(codeCoverageDir)/Products/Debug/\(self.name)Tests.xctest/Contents/MacOS/\(self.name)Tests"
            default:
                codeCoverageExecutablePath = "\(codeCoverageDir)/Products/Debug/\(executablePath)"
            }
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
        XcodeBuild.runTestsForXcodeProject(self.project.url.path!, schemeName: self.name)
    }
}