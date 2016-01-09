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
        try! SSZipArchive.unzipFileAtPath(zipPath, toDestination: fileManager.currentDirectoryPath, overwrite: false, password: nil)
        
        // Change working dir to see test Xcode project
        XcodeProject.fileManager.changeCurrentDirectoryPath("TestXcodeProjects")
    }
    
    override func tearDown() {
        let fileManager = NSFileManager.defaultManager()
        let currentDirURL = NSURL(string: fileManager.currentDirectoryPath)!
        fileManager.changeCurrentDirectoryPath(currentDirURL.URLByDeletingLastPathComponent!.absoluteString)
        try! fileManager.removeItemAtPath(currentDirURL.absoluteString)
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
        XCTAssertNotEqual(project?.url.lastPathComponent, testXcodeProjName)
        XCTAssertEqual(project?.url.lastPathComponent, "CommandLineTest.xcodeproj")
        XCTAssertEqual(project?.name, "CommandLineTest")
        
        // Move A.xcodeproj
        let aXcodeProjectName = "A.xcodeproj"
        try! fileManager.moveItemAtPath("A Project/" + aXcodeProjectName, toPath: aXcodeProjectName)
        
        // Make sure that A.xcodeproj is found before P
        let aProject = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertEqual(aXcodeProjectName, aProject?.url.lastPathComponent)
        XCTAssertEqual("A", aProject?.name)
    }
    
    func testTempDirSearch() {
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertNotNil(project?.tempRoot)
        if let tempDir = project?.tempRoot {
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(tempDir))
        }
    }
    
    func testTargets() {
        XCTAssertNotNil(XcodeProject.findXcodeProjectInCurrentDirectory()?.targets)
    }
}
