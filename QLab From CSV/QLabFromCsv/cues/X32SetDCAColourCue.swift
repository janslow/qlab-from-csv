
//
//  X32SetDCAColourCue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class X32SetDCAColourCue : X32DCACue {
    let colour : X32Colour
    
    override var cueName : String {
        return "X32 => DCA\(dca) => colour \(colour.rawValue)"
    }
    
    override var description : String {
        return "X32DCA\(dca)Colour"
    }
    
    init(patch: Int, dca: Int, colour: X32Colour, preWait: Float) {
        self.colour = colour
        super.init(patch: patch, dca: dca, dcaOscString: "config/color \(colour.rawValue)", preWait: preWait)
    }
}