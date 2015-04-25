//
//  X32AssignChannelToDCACue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class X32AssignChannelToDCACue: X32ChannelCue {
    let dca : Int?
    
    
    
    init(channel: Int, dca: Int?, preWait: Float) {
        self.dca = dca
        super.init(channel: channel, channelOscString: "grp/dca \(dca ?? 0)", preWait: preWait)
    }
}