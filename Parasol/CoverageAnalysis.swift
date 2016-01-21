//
//  CoverageAnalysis.swift
//  Parasol
//
//  Created by Kyle McAlpine on 20/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

struct CoverageAnalysis {
    let files: [CoverageFile]
    init(profdataPath: String, executablePath: String) throws {
        let coverageReportString = try XCRun.coverageWithFormat(.Analysis, profdataPath: profdataPath, executablePath: executablePath)
        var files = [CoverageFile]()
        var path: String?
        var lines = [String]()
        coverageReportString.enumerateLines { (line, stop) -> () in
            if line.characters.first == "/" {
                if let path = path {
                    files.append(CoverageFile(path: path, allLines: lines))
                }
                path = line
                lines = [String]()
            } else {
                lines.append(line)
            }
        }
        self.files = files
    }
}

struct CoverageFile {
    let path: String
    let allLines: [String]
}