//
//  main.swift
//  Parasol
//
//  Created by Kyle McAlpine on 30/12/2015.
//  Copyright © 2015 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

func argumentForOption(option: String) -> (optionFound: Bool, argument: String?) {
    for i in 0...Process.arguments.count - 1 {
        let argument = Process.arguments[i]
        if argument == option {
            return (true,  Process.arguments[safe: i + 1])
        }
    }
    return (false, nil)
}

var xcodeProject: XcodeProject?

var argumentResult = argumentForOption("--project")
if argumentResult.optionFound {
    if let argument = argumentResult.argument, let project = XcodeProject(url: NSURL(fileURLWithPath: argument)) {
        xcodeProject = project
    } else {
        print("ERROR: --project option set but no Xcode project exists at the passed URL")
        exit(1)
    }
}

guard let xcodeProject = xcodeProject ?? XcodeProject.findXcodeProjectInCurrentDirectory() else {
    print("Could not find Xcode project")
    exit(0)
}

var target: Target?
argumentResult = argumentForOption("--target")
if argumentResult.optionFound {
    if let argument = argumentResult.argument {
        for aTarget in xcodeProject.targets {
            if aTarget.name == argument {
                target = aTarget
                break
            }
        }
    }
    if target == nil {
        print("ERROR: --target option set but no target with passed name found in \(xcodeProject.url.lastPathComponent!)")
        exit(1)
    }
}

if target == nil {
    let targets = xcodeProject.targets
    print("Which target in \(xcodeProject.name):")
    for i in 1...targets.count {
        print("\(i)) \(targets[i - 1].name)")
    }
    let input = readLine()
    if let input = input, index = Int(input) where index - 1 >= 0 && index <= targets.count  {
        target = targets[index - 1]
    }
}

guard let target = target ?? xcodeProject.targets.first else {
    print("Couldn't find a target")
    exit(0)
}


if case .DoesNotExists = target.coverageDataExists {
    print("Coverage data has not been generated yet. Would you like to run tests? (y/n)")
    let input = readLine()
    if input == "y" {
        target.runTests()
    }
}

if case let .Exists(profdataPath, executablePath) = target.coverageDataExists {
    if let analysis = try? CoverageAnalysis(profdataPath: profdataPath, executablePath: executablePath) {
        print(analysis.toJSON())
    }
}


