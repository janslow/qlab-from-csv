//
//  X32SetChannelOnCue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class X32SetChannelMixOnCue : X32ChannelCue {
    let on : Bool
    
    override var cueName : String {
        let onString = on ? "on" : "off"
        return "X32 => Ch\(channel) => mix \(onString)"
    }
    
    override var description : String {
        return "X32Ch\(channel)MixOn"
    }
    
    init(channel: Int, on: Bool, preWait: Float) {
        self.on = on
        let onString = on ? "on" : "off"
        super.init(channel: channel, channelOscString: "mix/on \(onString)", preWait: preWait)
    }
}