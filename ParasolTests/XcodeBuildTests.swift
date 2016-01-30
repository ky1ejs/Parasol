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
        
        let fileManager = NSFileManager.defaultManager()
        
        // Unzip test Xcode project (Parasol.xcodeproj)
        let zipPath = NSBundle(forClass: self.dynamicType).pathForResource("TestXcodeProjects", ofType: "zip")
        try! SSZipArchive.unzipFileAtPath(zipPath, toDestination: fileManager.currentDirectoryPath, overwrite: false, password: nil)
        
        // Change working dir to see test Xcode project
        XcodeProject.fileManager.changeCurrentDirectoryPath("TestXcodeProjects")
    }
    
    override func tearDown() {
        let fileManager = NSFileManager.defaultManager()
        let currentDirURL = NSURL(string: fileManager.currentDirectoryPath)!
        fileManager.changeCurrentDirectoryPath(currentDirURL.URLByDeletingLastPathComponent!.path!)
        try! fileManager.removeItemAtPath(currentDirURL.path!)
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
