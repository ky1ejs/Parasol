//
//  TestXcodeProjects.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/01/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation
import ZipArchive

class TestXcodeProjects {
    static let mainProjectPath = NSURL(string: "CommandLineTest.xcodeproj")!
    static let secondProjectPath = NSURL(string: "A-Project/A.xcodeproj")!
    
    class func unzipTestProjects() {
        // Unzip test Xcode project (Parasol.xcodeproj)
        let zipPath = NSBundle(forClass: self).pathForResource("TestXcodeProjects", ofType: "zip")
        try! SSZipArchive.unzipFileAtPath(zipPath, toDestination: XcodeProject.fileManager.currentDirectoryPath, overwrite: false, password: nil)
        
        // Change working dir to see test Xcode project
        XcodeProject.fileManager.changeCurrentDirectoryPath("TestXcodeProjects")
    }
    
    class func cleanUp() {
        let currentDirURL = NSURL(string: XcodeProject.fileManager.currentDirectoryPath)!
        XcodeProject.fileManager.changeCurrentDirectoryPath(currentDirURL.URLByDeletingLastPathComponent!.path!)
        try! XcodeProject.fileManager.removeItemAtPath(currentDirURL.path!) // fileManager will automatically move to parent
    }
}
