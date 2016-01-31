//
//  start_cue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 20/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class StartCue : Cue, CustomStringConvertible {
    var cueNumber : String? {
        return nil
    }
    var cueName : String {
        return "Start \(targetNumber)"
    }
    var description : String {
        return targetNumber
    }
    var preWait : Float
    var targetNumber : String
    
    init(targetNumber : String, preWait : Float = 0) {
        self.targetNumber = targetNumber
        self.preWait = preWait
    }
}