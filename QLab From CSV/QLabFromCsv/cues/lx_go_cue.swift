//
//  lx_cue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 20/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class LxGoCue : Cue {
    var cueNumber : String? {
        return nil
    }
    var cueName : String {
        return "LX \(lxNumber) Go"
    }
    var description : String {
        return "LX\(lxNumber)"
    }
    var preWait : Float
    var lxNumber : String
    
    init(lxNumber : String, preWait : Float) {
        self.lxNumber = lxNumber
        self.preWait = preWait
    }
}