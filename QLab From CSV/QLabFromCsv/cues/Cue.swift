//
//  cue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 20/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

public protocol Cue {
    var cueNumber : String? { get }
    var cueName : String { get }
    var description : String { get }
    var preWait : Float { get set }
}