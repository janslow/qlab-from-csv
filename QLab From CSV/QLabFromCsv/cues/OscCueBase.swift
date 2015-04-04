//
//  OscCueBase.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-04.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

@objc class OscCueBase {
    private var _patch = 1
    
    var patch : Int {
        get {
            return _patch
        }
        set {
            if newValue < 1 || newValue > 16 {
                log.error("OscCueBase: OSC Patch must be between 1 and 16 (was \(newValue))")
                return
            }
            _patch = newValue
        }
    }
}