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
    var coverage: Float {
        var testableLines: Float = 0
        var testedLines: Float = 0
        for file in files {
            testableLines += Float(file.testableLines.count)
            testedLines += Float(file.testedLines.count)
        }
        return (testedLines / testableLines) * 100
    }
    
    init(profdataPath: String, executablePath: String) throws {
        let coverageReportString = try XCRun.coverageWithFormat(.Analysis, profdataPath: profdataPath, executablePath: executablePath)
        var files = [CoverageFile]()
        var path: String?
        var lines = [String]()
        let whiteSpaceRegex = try! NSRegularExpression(pattern: "^\\s*$", options: [])
        coverageReportString.enumerateLines { (line, stop) -> () in
            if line.characters.first == "/" {
                path = line
                lines = [String]()
            } else if whiteSpaceRegex.matchesInString(line, options: [], range: NSMakeRange(0, line.characters.count)).count > 0 {
                if let path = path {
                    files.append(CoverageFile(path: path, allLines: lines))
                }
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
    let testableLines: [String]
    let testedLines: [String]
    var coverage: Float { return (Float(self.testedLines.count) / Float(self.testableLines.count)) * 100 }
    
    init(path: String, allLines: [String]) {
        let coverageRegex = try! NSRegularExpression(pattern: "^\\s+\\d", options: [])
        var testableLines = [String]()
        var testedLines = [String]()
        for line in allLines {
            if line.characters.count > 0 {
                if let result = coverageRegex.firstMatchInString(line, options: [], range: NSMakeRange(0, line.characters.count)) {
                    var match = (line as NSString).substringWithRange(result.range)
                    match = match.stringByReplacingOccurrencesOfString(" ", withString: "")
                    if let coverageNumber = Int(match) {
                        testableLines.append(line)
                        if coverageNumber > 0 {
                            testedLines.append(line)
                        }
                    }
                }
            }
        }
        self.path = path
        self.allLines = allLines
        self.testableLines = testableLines
        self.testedLines = testedLines
    }
}