//
//  CuesViewController.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 10/02/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public protocol CuesViewController {
    var Cues : [Cue] { get }
    
    var IsValid : Bool { get }
}