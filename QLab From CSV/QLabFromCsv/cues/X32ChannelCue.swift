
//
//  X32ChannelCue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class X32ChannelCue : OscCueBase, OscCustomCue {
    var cueNumber : String? {
        return nil
    }
    var cueName : String {
        return "X32 => Ch\(channel) => \(channelOscString)"
    }
    var description : String {
        return "X32Ch\(channel)"
    }
    let preWait : Float
    var customString : String {
        get {
            let channelString = String(format: "%02d", channel)
            return "/ch/\(channelString)/\(channelOscString)"
        }
    }
    let channel : Int
    let channelOscString : String
    
    init(channel : Int, channelOscString : String, preWait : Float) {
        self.channel = channel
        self.channelOscString = channelOscString
        self.preWait = preWait
    }
}
