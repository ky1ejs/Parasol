//
//  XcodeProject.swift
//  Parasol
//
//  Created by Kyle McAlpine on 31/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

struct XcodeProject {
    var name: String
    
    var tempDir: String? {
        let task = NSTask()
        task.launchPath = "/usr/bin/xcodebuild" // TODO: make optional argument
        task.arguments = ["-project", self.name, "-scheme", "Parasol", "-showBuildSettings"]
        let outputPipe = NSPipe()
        task.standardOutput = outputPipe
        task.launch()
        task.waitUntilExit()
        
        var tempDirPath: String?
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if let outputString = String(data: outputData, encoding: NSUTF8StringEncoding) {
            let regex = try! NSRegularExpression(pattern: "^\\s*TEMP_ROOT = ", options: [])
            outputString.enumerateLines({ (line, stop) -> () in
                let mutableLine = NSMutableString(string: line)
                if regex.replaceMatchesInString(mutableLine as NSMutableString, options: [], range: NSMakeRange(0, mutableLine.length), withTemplate: "") == 1 {
                    tempDirPath = mutableLine as String
                    stop = true
                }
            })
        }
        return tempDirPath
    }
    
    static func findXcodeProjectInCurrentDirectory() -> XcodeProject? {
        let fileManager = NSFileManager.defaultManager()
        var xcodeProject: XcodeProject?
        do {
            let files = try fileManager.contentsOfDirectoryAtPath(fileManager.currentDirectoryPath)
            for file in files {
                if (file as NSString).pathExtension == "xcodeproj" {
                    xcodeProject = XcodeProject(name: file)
                }
            }
        } catch {
            
        }
        return xcodeProject
    }
}
