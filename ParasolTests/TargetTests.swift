//
//  TargetTests.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import XCTest

class TargetTests: XCTestCase {
    var target: Target!

    override func setUp() {
        super.setUp()
        TestXcodeProjects.unzipTestProjects()
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertNotNil(project?.targets.first)
        self.target = project?.targets.first
    }
    
    override func tearDown() {
        TestXcodeProjects.cleanUp()
        super.tearDown()
    }
    
    func testBuildSettings() {
        XCTAssertNotNil(self.target.buildSettings)
    }
    
    func testExecutablePath() {
        XCTAssertNotNil(self.target.executablePath)
    }
    
    func testCodeCoverageDir() {
        XCTAssertNotNil(self.target.codeCoverageDir)
    }
    
    func testCodeCoverageProfDataPath() {
        XCTAssertNotNil(self.target.codeCoverageProfdataPath)
    }
    
    func testCodeCoverageExecutablePath() {
        XCTAssertNotNil(self.target.codeCoverageExecutablePath)
    }
    
}
