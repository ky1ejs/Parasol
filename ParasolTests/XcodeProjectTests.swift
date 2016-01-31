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
        TestXcodeProjects.unzipTestProjects()
    }
    
    override func tearDown() {
        TestXcodeProjects.cleanUp()
        super.tearDown()
    }
    
    func testXcodeProjectNameSearch() {
        let fileManager = NSFileManager.defaultManager()
        
        // Create project file that should not be found as P comes before T
        let testXcodeProjName = "Test.xcodeproj"
        fileManager.createFileAtPath(testXcodeProjName, contents: nil, attributes: nil)
        
        var project: XcodeProject?
        // Search for Xcode project
        self.measureBlock { () -> Void in
            project = XcodeProject.findXcodeProjectInCurrentDirectory()
        }
        
        // Assert that its not Test.xcodeproj file we made
        XCTAssertNotEqual(project?.url.lastPathComponent, testXcodeProjName)
        XCTAssertEqual(project?.url.lastPathComponent, TestXcodeProjects.mainProjectPath.lastPathComponent)
        XCTAssertEqual(project?.name, (TestXcodeProjects.mainProjectPath.lastPathComponent! as NSString).stringByDeletingPathExtension)
        
        // Move A.xcodeproj
        try! fileManager.moveItemAtPath(TestXcodeProjects.secondProjectPath.path!, toPath: TestXcodeProjects.secondProjectPath.lastPathComponent!)
        
        // Make sure that A.xcodeproj is found before P
        let aProject = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertEqual(TestXcodeProjects.secondProjectPath.lastPathComponent, aProject?.url.lastPathComponent)
        XCTAssertEqual(aProject?.name, (TestXcodeProjects.secondProjectPath.lastPathComponent! as NSString).stringByDeletingPathExtension)
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
    
    func testFailableIntialiser() {
        let fileManager = NSFileManager.defaultManager()
        let fakeProjectPath = "Fake.xcodeproj"
        fileManager.createFileAtPath(fakeProjectPath, contents: nil, attributes: nil)
        XCTAssertNil(XcodeProject(url: NSURL(string: fakeProjectPath)!))
        _ = try? fileManager.removeItemAtPath(fakeProjectPath)
    }
}
