//
//  OscUdpCue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 17/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

@objc protocol OscUdpCue : OscCue {
    var udpString : String { get }
}