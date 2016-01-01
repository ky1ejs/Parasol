//
//  XcodeProjectTests.swift
//  XcodeProjectTests
//
//  Created by Kyle McAlpine on 31/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import XCTest
import Foundation
@testable import Parasol

class XcodeProjectTests: XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = true
    }
    
    func testXcodeProjectNameSearch() {
        let fileManager = NSFileManager.defaultManager()
        let xcodeProjName = "Test.xcodeproj"
        let xcodeProjPath = "\(fileManager.currentDirectoryPath)/\(xcodeProjName)"
        fileManager.createFileAtPath(xcodeProjPath, contents: nil, attributes: nil)
        XCTAssertNotNil(XcodeProject.findXcodeProjectInCurrentDirectory())
        _ = try? NSFileManager.defaultManager().removeItemAtPath(xcodeProjPath)
    }
}
