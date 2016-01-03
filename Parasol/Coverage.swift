//
//  Coverage.swift
//  Parasol
//
//  Created by Kyle McAlpine on 03/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

struct Coverage {
    static func showCoverage(profdataPath: String, executablePath: String) {
        let task = NSTask()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["llvm-cov", "show", "-instr-profile", profdataPath, executablePath]
        task.launch()
        task.waitUntilExit()
    }
}