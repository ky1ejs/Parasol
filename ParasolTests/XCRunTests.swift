//
//  XCRunTests.swift
//  Parasol
//
//  Created by Kyle McAlpine on 01/02/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import XCTest

class XCRunTests: XCTestCase {

    override func setUp() {
        super.setUp()
        TestXcodeProjects.unzipTestProjects()
    }
    
    override func tearDown() {
        TestXcodeProjects.cleanUp()
        super.tearDown()
    }
    
    func testCoverageWithFormat() {
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertNotNil(project?.targets.first)
        let target = project!.targets.first!
        target.runTests()
        let coverage = try? XCRun.coverageWithFormat(.Analysis, profdataPath: target.codeCoverageProfdataPath!, executablePath: target.executablePath!)
        XCTAssertNotNil(coverage)
    }
}
