//
//  ArrayExtensions.swift
//  Parasol
//
//  Created by Kyle McAlpine on 04/02/2016.
//  Copyright © 2016 Loot Financial Services Ltd. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}