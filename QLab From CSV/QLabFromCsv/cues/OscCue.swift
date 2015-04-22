//
//  OscCue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-04.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public protocol OscCue : Cue {
    var patch : Int { get }
}