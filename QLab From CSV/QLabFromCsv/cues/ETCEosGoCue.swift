//
//  lx_cue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 20/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class ETCEosGoCue : OscCueBase, OscUdpCue, CustomStringConvertible {
    var cueNumber : String? {
        return nil
    }
    var cueName : String {
        if lxCueList == 0 {
            return "ETC Eos Cue \(lxNumber) Go (OSC\(patch))"
        } else {
            return "ETC Eos Cue \(lxNumber) in Cue List \(lxCueList) Go (OSC\(patch))"
        }
    }
    var description : String {
        if lxCueList == 0 {
            return "EosGo\(lxNumber)"
        } else {
            return "EosGo\(lxCueList)/\(lxNumber)"
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