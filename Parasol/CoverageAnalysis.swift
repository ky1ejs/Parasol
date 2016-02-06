//
//  CoverageAnalysis.swift
//  Parasol
//
//  Created by Kyle McAlpine on 20/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

struct CoverageAnalysis: JSONEncodeable {
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
                path = path?.stringByReplacingOccurrencesOfString("\(XcodeProject.fileManager.currentDirectoryPath)/", withString: "")
                if let path = path, file = CoverageFile(path: path, allLines: lines) {
                    files.append(file)
                }
            } else {
                lines.append(line)
            }
        }
        self.files = files
    }
    
    func toJSON() -> [String : AnyObject] {
        var rootDict = [String : AnyObject]()
        rootDict["coverage"] = self.coverage
        rootDict["files"] = self.files.map(CoverageFile.toJSON).map({ $0() })
        return rootDict
    }
}

struct CoverageFile: JSONEncodeable {
    let path: String
    let allLines: [String]
    let testableLines: [String]
    let testedLines: [String]
    var coverage: Float { return (Float(self.testedLines.count) / Float(self.testableLines.count)) * 100 }
    
    init?(path: String, allLines: [String]) {
        let testFileRegex = try! NSRegularExpression(pattern: "^*Tests.*$", options: [])
        guard testFileRegex.matchesInString(path, options: [], range: NSMakeRange(0, path.characters.count)).count == 0 else {
            return nil
        }
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
    
    func toJSON() -> [String : AnyObject] {
        var json = [String : AnyObject]()
        json["path"]            = self.path
        json["coverage"]        = self.coverage
        json["testable_lines"]  = self.testableLines.count
        json["tested_lines"]    = self.testedLines.count
        return json
    }
}