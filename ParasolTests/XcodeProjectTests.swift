//
//  XcodeProjectTests.swift
//  XcodeProjectTests
//
//  Created by Kyle McAlpine on 31/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import XCTest
import Foundation
//import Parasol
@testable import Parasol

class XcodeProjectTests: XCTestCase {
    let xcodeProjName = "Test.xcodeproj"
    let xcodeProjPath = "\(NSFileManager.defaultManager().currentDirectoryPath)/Test.xcodeproj"
    
    override func setUp() {
        super.setUp()
        NSFileManager.defaultManager().createFileAtPath(self.xcodeProjPath, contents: nil, attributes: nil)
    }
    
    override func tearDown() {
        _ = try? NSFileManager.defaultManager().removeItemAtPath(self.xcodeProjPath)
        super.tearDown()
    }
    
    func testXcodeProjectNameSearch() {
        XCTAssertEqual(XcodeProject.xcodeProjectName(), self.xcodeProjName)
    }
}
