//
//  X32AssignChannelToDCACue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class X32AssignChannelToDCACue : X32ChannelCue {
    let dca : Int?
    
    override var cueName : String {
        if let dca1 = dca {
            return "X32 => Ch\(channel) => assign to DCA \(dca1)"
        } else {
            return "X32 => Ch\(channel) => unassign from DCA"
        }
    }
    
    override var description : String {
        return "X32Ch\(channel)DCA"
    }
    
    init(channel: Int, dca: Int?, preWait: Float) {
        self.dca = dca
        super.init(channel: channel, channelOscString: "grp/dca \(dca ?? 0)", preWait: preWait)
    }
}
