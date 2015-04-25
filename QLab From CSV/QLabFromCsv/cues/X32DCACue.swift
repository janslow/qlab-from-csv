//
//  X32DCACue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class X32DCACue : OscCueBase, OscCustomCue {
    var cueNumber : String? {
        return nil
    }
    var cueName : String {
        return "X32 => DCA\(dca) => \(dcaOscString)"
    }
    var description : String {
        return "X32DCA\(dca)"
    }
    let preWait : Float
    var customString : String {
        get {
            return "/dca/\(dca)/\(dcaOscString)"
        }
    }
    let dca : Int
    let dcaOscString : String
    
    init(dca : Int, dcaOscString : String, preWait : Float) {
        self.dca = dca
        self.dcaOscString = dcaOscString
        self.preWait = preWait
    }
}