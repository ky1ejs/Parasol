//
//  XcodeProjectTests.swift
//  XcodeProjectTests
//
//  Created by Kyle McAlpine on 31/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import XCTest
import Foundation
import ZipArchive

class XcodeProjectTests: XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = true
        
        // Unzip test Xcode project (Parasol.xcodeproj)
        let zipPath = NSBundle(forClass: self.dynamicType).pathForResource("ParasolTest", ofType: "zip")
        _ = try? SSZipArchive.unzipFileAtPath(zipPath, toDestination: NSFileManager.defaultManager().currentDirectoryPath, overwrite: false, password: nil)
        
        // Change working dir to see test Xcode project
        XcodeProject.fileManager.changeCurrentDirectoryPath("ParasolTest")
    }
    
    func testXcodeProjectNameSearch() {
        // Create project file that should not be found as P comes before T
        let testXcodeProjName = "Test.xcodeproj"
        XcodeProject.fileManager.createFileAtPath(testXcodeProjName, contents: nil, attributes: nil)
        
        // Search for Xcode project
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        
        // Assert that its not Test.xcodeproj file we made
        XCTAssertNotEqual(XcodeProject.findXcodeProjectInCurrentDirectory()?.name, testXcodeProjName)
        XCTAssertEqual(project?.name, "Parasol.xcodeproj")
        
        // Create project that should come before P
        let aXcodeProjectName = "A.xcodeproj"
        XcodeProject.fileManager.createFileAtPath(aXcodeProjectName, contents: nil, attributes: nil)
        
        // Make sure that A.xcodeproj is found before P
        let aProject = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertEqual(aXcodeProjectName, aProject?.name)
        
        // Clean up
        _ = try? XcodeProject.fileManager.removeItemAtPath(testXcodeProjName)
        _ = try? XcodeProject.fileManager.removeItemAtPath(aXcodeProjectName)
    }
    
    func testTempDirSearch() {
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertNotNil(project?.tempRoot)
        if let tempDir = project?.tempRoot {
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(tempDir))
        }
    }
}
