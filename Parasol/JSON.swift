//
//  JSON.swift
//  Parasol
//
//  Created by Kyle McAlpine on 03/02/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

protocol JSONEncodeable {
    func toJSON() -> [String : AnyObject]
}