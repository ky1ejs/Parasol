//
//  XCRun.swift
//  Parasol
//
//  Created by Kyle McAlpine on 20/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

enum XCRunError: ErrorType {
    case UnparsableResult
}

enum XCRunCoverageFormat: String {
    case Analysis = "show"
    case Report = "report"
}

struct XCRun {
    static var launchPath: String = {
        let task = NSTask()
        task.launchPath = "/usr/bin/which"
        task.arguments = ["xcrun"]
        let outpipe = NSPipe()
        task.standardOutput = outpipe
        task.launch()
        task.waitUntilExit()
        if let path = String(data: outpipe.fileHandleForReading.readDataToEndOfFile(), encoding:  NSUTF8StringEncoding) {
            return path.stringByReplacingOccurrencesOfString("\n", withString: "")
        }
        return "/usr/bin/xcrun"
    }()
    
    
    static func coverageWithFormat(format: XCRunCoverageFormat, profdataPath: String, executablePath: String) throws -> String {
        let task = NSTask()
        task.launchPath = self.launchPath
        task.arguments = ["llvm-cov", format.rawValue, "-instr-profile", profdataPath, executablePath]
        let outpipe = NSPipe()
        task.standardOutput = outpipe
        task.launch()
        task.waitUntilExit()
        if let analysis = String(data: outpipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding) {
            return analysis
        }
        throw XCRunError.UnparsableResult
    }
}