//
//  Coverage.swift
//  Parasol
//
//  Created by Kyle McAlpine on 03/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

struct Coverage {
    let lines: [String]
    
    init(coverageReport: String) throws {
        var lines = [String]()
        coverageReport.enumerateLines { (line, stop) -> () in
            lines.append(line)
        }
        self.lines = lines
    }
    
    static func showCoverage(profdataPath: String, executablePath: String) {
        let task = NSTask()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["llvm-cov", "show", "-instr-profile", profdataPath, executablePath]
        task.launch()
        task.waitUntilExit()
    }
    
    static func showCoverageReport(profdataPath: String, executablePath: String) -> Coverage {
        let task = NSTask()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["llvm-cov", "report", "-instr-profile", profdataPath, executablePath]
        let outPipe = NSPipe()
        task.standardOutput = outPipe
        task.launch()
        task.waitUntilExit()
        let report = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)!
        return try! Coverage(coverageReport: report)
    }
}