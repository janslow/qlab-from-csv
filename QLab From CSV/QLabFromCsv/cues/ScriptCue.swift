//
//  ScriptCue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 31/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

@objc protocol ScriptCue : Cue {
    var scriptString : String { get }
}