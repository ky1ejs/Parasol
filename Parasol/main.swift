//
//  main.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

// TODO: make passing Xcode project as an optional argument
if let xcodeProject = XcodeProject.findXcodeProjectInCurrentDirectory(), coverageProfdataPath = xcodeProject.coverageProfdataPath, codeCoverageExecutablePath = xcodeProject.codeCoverageExecutablePath {
    print(coverageProfdataPath)
    print(codeCoverageExecutablePath)
    let task = NSTask()
    task.launchPath = "/usr/bin/xcrun"
    task.arguments = ["llvm-cov", "show", "-instr-profile", coverageProfdataPath, codeCoverageExecutablePath]
    task.launch()
    task.waitUntilExit()
} else {
    print("Couldn't find an Xcode project")
}



