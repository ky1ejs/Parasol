//
//  main.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

// TODO: make passing Xcode project as an optional argument
if let xcodeProject = XcodeProject.findXcodeProjectInCurrentDirectory() {
    
} else {
    print("Couldn't find an Xcode project")
}



