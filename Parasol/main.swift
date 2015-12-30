//
//  main.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

let fileManager = NSFileManager.defaultManager()

do {
    let files = try fileManager.contentsOfDirectoryAtPath(fileManager.currentDirectoryPath)
    var xcodeProjectName: String?
    print(files)
    for file in files {
        print(file)
        print((file as NSString).pathExtension)
        if (file as NSString).pathExtension == "xcodeproj" {
            xcodeProjectName = file
        }
    }
    print(xcodeProjectName)
} catch {
    
}



