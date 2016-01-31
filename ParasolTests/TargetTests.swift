//
//  TargetTests.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import XCTest

class TargetTests: XCTestCase {

    override func setUp() {
        super.setUp()
        TestXcodeProjects.unzipTestProjects()
    }
    
    override func tearDown() {
        TestXcodeProjects.cleanUp()
        super.tearDown()
    }
}
