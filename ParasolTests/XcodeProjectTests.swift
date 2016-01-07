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
        
        let fileManager = NSFileManager.defaultManager()
        
        // Unzip test Xcode project (Parasol.xcodeproj)
        let zipPath = NSBundle(forClass: self.dynamicType).pathForResource("TestXcodeProjects", ofType: "zip")
        _ = try! SSZipArchive.unzipFileAtPath(zipPath, toDestination: fileManager.currentDirectoryPath, overwrite: false, password: nil)
        
        // Change working dir to see test Xcode project
        _ = try? fileManager.moveItemAtPath(fileManager.currentDirectoryPath + "/TestXcodeProjects/CommandLineTest/CommandLineTest.xcodeproj", toPath: fileManager.currentDirectoryPath + "/CommandLineTest.xcodeproj")
    }
    
    override func tearDown() {
        let fileManager = NSFileManager()
        try! fileManager.removeItemAtPath(fileManager.currentDirectoryPath + "/CommandLineTest.xcodeproj")
        try! fileManager.removeItemAtPath(fileManager.currentDirectoryPath + "/TestXcodeProjects")
        super.tearDown()
    }
    
    func testXcodeProjectNameSearch() {
        let fileManager = NSFileManager.defaultManager()
        
        // Create project file that should not be found as P comes before T
        let testXcodeProjName = "Test.xcodeproj"
        fileManager.createFileAtPath(testXcodeProjName, contents: nil, attributes: nil)
        
        // Search for Xcode project
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        
        // Assert that its not Test.xcodeproj file we made
        XCTAssertNotEqual(project?.name, testXcodeProjName)
        XCTAssertEqual(project?.name, "CommandLineTest.xcodeproj")
        
        // Create project that should come before P
        let aXcodeProjectName = "A.xcodeproj"
        fileManager.createFileAtPath(aXcodeProjectName, contents: nil, attributes: nil)
        
        // Make sure that A.xcodeproj is found before P
        let aProject = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertEqual(aXcodeProjectName, aProject?.name)
        
        // Clean up
        _ = try? fileManager.removeItemAtPath(testXcodeProjName)
        _ = try? fileManager.removeItemAtPath(aXcodeProjectName)
    }
    
    func testTempDirSearch() {
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertNotNil(project?.tempRoot)
        if let tempDir = project?.tempRoot {
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(tempDir))
        }
    }
}
