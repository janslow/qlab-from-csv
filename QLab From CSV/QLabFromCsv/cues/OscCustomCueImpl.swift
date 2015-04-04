//
//  OscCustomCueImpl.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-04.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class OscCustomCueImpl : OscCueBase, OscCustomCue, Printable {
    var cueNumber : String? {
        return nil
    }
    var cueName : String {
        return "OSC\(patch) => \(customString)"
    }
    var description : String {
        return "OSC\(patch)"
    }
    var preWait : Float
    var customString : String
    
    init(customString : String, preWait : Float) {
        self.customString = customString
        self.preWait = preWait
    }
}