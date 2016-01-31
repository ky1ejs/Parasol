//
//  XcodeBuild.swift
//  Parasol
//
//  Created by Kyle McAlpine on 09/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

struct XcodeBuild {
    static private let xcodeBuildPath = "/usr/bin/xcodebuild"
    
    static func buildSettingsForXcodeProject(projectPath: String, schemeName: String?) -> String? {
        let task = NSTask()
        task.launchPath = self.xcodeBuildPath // TODO: make optional argument
        var arguments = ["-project", projectPath]
        if let schemeName = schemeName {
            arguments += ["-scheme", schemeName]
        }
        arguments.append("-showBuildSettings")
        task.arguments = arguments
        let outputPipe = NSPipe()
        task.standardError = NSPipe() // Don't print errors
        task.standardOutput = outputPipe
        task.launch()
        task.waitUntilExit()
        return String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
    }
    
    static func runTestsForXcodeProject(projectPath: String, schemeName: String?) {
        let task = NSTask()
        task.launchPath = self.xcodeBuildPath
        var arguments = ["test", "-project", projectPath]
        if let schemeName = schemeName {
            arguments += ["-scheme", schemeName]
        }
        arguments += ["-enableCodeCoverage", "YES"]
        task.arguments = arguments
        task.launch()
        print("testing...")
        task.waitUntilExit()
    }
}
