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
    
    init(patch: Int, channel: Int, dca dcaNillable: Int?, preWait: Float) {
        self.dca = dcaNillable
        let dcaBitmap : Int
        if let dca = dcaNillable {
            dcaBitmap = 1 << (dca - 1)
        } else {
            dcaBitmap = 0
        }
        super.init(patch: patch, channel: channel, channelOscString: "grp/dca \(dcaBitmap)", preWait: preWait)
    }
}
