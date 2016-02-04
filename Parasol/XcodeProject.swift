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
    static let fileManager = NSFileManager()
    
    let url: NSURL
    let name: String
    var projectFile: XCProjectFile
    
    init?(url: NSURL) {
        var projectName: String?
        let regex = try! NSRegularExpression(pattern: "^\\s*PROJECT_NAME = ", options: [])
        XcodeBuild.buildSettingsForXcodeProject(url.path!, schemeName: nil)?.enumerateLines { (line, stop) -> () in
            let mutableLine = NSMutableString(string: line)
            if regex.replaceMatchesInString(mutableLine as NSMutableString, options: [], range: NSMakeRange(0, mutableLine.length), withTemplate: "") == 1 {
                projectName = mutableLine as String
                stop = true
            }
        }
        if let projectName = projectName, projectFile = try? XCProjectFile(xcodeprojURL: url) {
            self.url = url
            self.name = projectName
            self.projectFile = projectFile
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
        return XcodeBuild.buildSettingsForXcodeProject(self.url.path!, schemeName: nil)
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
        let urls = try! self.fileManager.contentsOfDirectoryAtURL(NSURL(string: self.fileManager.currentDirectoryPath)!, includingPropertiesForKeys: nil, options: [])
        for url in urls where (url.lastPathComponent! as NSString).pathExtension == "xcodeproj" {
            if let foundProject = XcodeProject(url: url) {
                xcodeProject = foundProject
                break
            }
        }
        return xcodeProject
    }
}
