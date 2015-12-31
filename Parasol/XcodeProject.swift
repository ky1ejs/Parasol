//
//  XcodeProject.swift
//  Parasol
//
//  Created by Kyle McAlpine on 31/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

struct XcodeProject {
    static func xcodeProjectName() -> String? {
        let fileManager = NSFileManager.defaultManager()
        var xcodeProjectName: String?
        do {
            let files = try fileManager.contentsOfDirectoryAtPath(fileManager.currentDirectoryPath)
            print(files)
            for file in files {
                print(file)
                print((file as NSString).pathExtension)
                if (file as NSString).pathExtension == "xcodeproj" {
                    xcodeProjectName = file
                }
            }
        } catch {
            
        }
        return xcodeProjectName
    }
}
