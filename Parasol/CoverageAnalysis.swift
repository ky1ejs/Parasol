//
//  CoverageAnalysis.swift
//  Parasol
//
//  Created by Kyle McAlpine on 20/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

struct CoverageAnalysis {
    let lines: [String]
    init(profdataPath: String, executablePath: String) throws {
        let coverageReportString = try XCRun.coverageWithFormat(.Analysis, profdataPath: profdataPath, executablePath: executablePath)
        var lines = [String]()
        coverageReportString.enumerateLines { (line, stop) -> () in
            lines.append(line)
        }
        self.lines = lines
    }
}