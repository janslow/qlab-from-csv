//
//  lx_cue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 20/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class LxGoCue : OscCueBase, OscUdpCue, Printable {
    var cueNumber : String? {
        return nil
    }
    var cueName : String {
        if lxCueList == 0 {
            return "LX \(lxNumber) Go (OSC:\(patch))"
        } else {
            return "LX \(lxNumber) in Cue List \(lxCueList) Go (OSC:\(patch))"
        }
    }
    var description : String {
        if lxCueList == 0 {
            return "LX\(lxNumber)"
        } else {
            return "LX\(lxCueList)/\(lxNumber)"
        }
    }
    var preWait : Float
    var lxNumber : String
    var lxCueList : Int = 0
    var udpString : String {
        return "Cue \(lxCueList) \(lxNumber) #"
    }
    
    init(lxNumber : String, preWait : Float) {
        self.lxNumber = lxNumber
        self.preWait = preWait
    }
}