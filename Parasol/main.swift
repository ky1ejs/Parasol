//
//  main.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

// TODO: make passing Xcode project as an optional argument
if let xcodeProject = XcodeProject.findXcodeProjectInCurrentDirectory() {
    if case let .Exists(profdataPath, executablePath) = xcodeProject.coverageDataExists {
        print(profdataPath)
        print(executablePath)
        let task = NSTask()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["llvm-cov", "show", "-instr-profile", profdataPath, executablePath]
        task.launch()
        task.waitUntilExit()
    } else {
        print("Coverage data has not been generated. Would you like to run tests? (y/n)")
        let input = readLine()
        if input == "y" {
            let task = NSTask()
            task.launchPath = "/usr/bin/xcodebuild"
            task.arguments = ["test", "-project", xcodeProject.name, "-scheme", "Parasol", "-enableCodeCoverage", "YES"]
            print(task.arguments)
            task.launch()
            task.waitUntilExit()
            print(xcodeProject.coverageDataExists)
        } else if input == "n" {
            
        }
    }
} else {
    print("Couldn't find an Xcode project")
}


