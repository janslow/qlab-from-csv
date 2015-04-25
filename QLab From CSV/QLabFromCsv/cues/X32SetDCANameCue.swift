//
//  X32SetDCANameCue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class X32SetDCANameCue : X32DCACue {
    let name : String
    
    override var cueName : String {
        return "X32 => DCA\(dca) => name \"\(name)\""
    }
    
    override var description : String {
        return "X32DCA\(dca)Name"
    }
    
    init(dca: Int, name: String, preWait: Float) {
        self.name = name
        super.init(dca: dca, dcaOscString: "config/name \"\(name)\"", preWait: preWait)
    }
}