//
//  XcodeBuildTests.swift
//  Parasol
//
//  Created by Kyle McAlpine on 28/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import XCTest
import ZipArchive

class XcodeBuildTests: XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = true
        TestXcodeProjects.unzipTestProjects()
    }
    
    override func tearDown() {
        TestXcodeProjects.cleanUp()
        super.tearDown()
    }
    
    func testRunTests() {
        XcodeBuild.runTestsForXcodeProject("CommandLineTest.xcodeproj", schemeName: "CommandLineTest")
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertNotNil(project)
        var testTarget: Target?
        for target in project!.targets {
            if target.targetFile.productType == .UnitTest {
                testTarget = target
                break
            }
        }
        XCTAssertNotNil(testTarget, "The test project does not have a Unit Test target")
        self.measureBlock { () -> Void in
            project?.runTestsForScheme(project?.targets.first?.name)
        }
        let coverageDir = project?.targets.first?.codeCoverageDir
        XCTAssertNotNil(coverageDir)
        print(coverageDir)
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(coverageDir!))
    }
    
    
}
