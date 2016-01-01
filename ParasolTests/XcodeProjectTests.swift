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
@testable import Parasol

class XcodeProjectTests: XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = true
    }
    
    func testXcodeProjectNameSearch() {
        let zipPath = NSBundle(forClass: self.dynamicType).pathForResource("ParasolTest", ofType: "zip")
        _ = try? SSZipArchive.unzipFileAtPath(zipPath, toDestination: NSFileManager.defaultManager().currentDirectoryPath, overwrite: false, password: nil)
        XcodeProject.fileManager.changeCurrentDirectoryPath("ParasolTest")
        print(try? XcodeProject.fileManager.contentsOfDirectoryAtPath(XcodeProject.fileManager.currentDirectoryPath))
        let testXcodeProjName = "Test.xcodeproj"
        XcodeProject.fileManager.createFileAtPath(testXcodeProjName, contents: nil, attributes: nil)
        let project = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertNotEqual(XcodeProject.findXcodeProjectInCurrentDirectory()?.name, testXcodeProjName)
        XCTAssertEqual(project?.name, "Parasol.xcodeproj")
        _ = try? XcodeProject.fileManager.removeItemAtPath(testXcodeProjName)
        let aXcodeProjectName = "A.xcodeproj"
        XcodeProject.fileManager.createFileAtPath(aXcodeProjectName, contents: nil, attributes: nil)
        let aProject = XcodeProject.findXcodeProjectInCurrentDirectory()
        XCTAssertEqual(aXcodeProjectName, aProject?.name)
        _ = try? XcodeProject.fileManager.removeItemAtPath(aXcodeProjectName)
    }
}
