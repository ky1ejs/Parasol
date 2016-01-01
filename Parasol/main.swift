//
//  main.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

// TODO: make passing Xcode project as an optional argument
if let xcodeProjectName = XcodeProject.xcodeProjectName() {
    let task = NSTask()
    task.launchPath = "/usr/bin/xcodebuild" // TODO: make optional argument
    task.arguments = ["-project", xcodeProjectName, "-scheme", "Parasol", "-showBuildSettings"]
    let outputPipe = NSPipe()
    task.standardOutput = outputPipe
    task.launch()
    task.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    if let outputString = String(data: outputData, encoding: NSUTF8StringEncoding) {
        var derivedDataPath: String?
        let regex = try! NSRegularExpression(pattern: "^\\s*TEMP_ROOT = ", options: [])
        outputString.enumerateLines({ (line, stop) -> () in
            let mutableLine = NSMutableString(string: line)
            if regex.replaceMatchesInString(mutableLine as NSMutableString, options: [], range: NSMakeRange(0, mutableLine.length), withTemplate: "") == 1 {
                derivedDataPath = mutableLine as String
                stop = true
            }
        })
    }
    print(task.standardOutput)
} else {
    print("Couldn't find an Xcode project")
}



