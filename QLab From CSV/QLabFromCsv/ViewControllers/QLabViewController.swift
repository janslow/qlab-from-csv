//
//  ViewController.swift
//  QLabFromCsv
//
//  Created by Jay Anslow on 24/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Cocoa
import AppKit

public protocol QLabViewController {
    var Workspace : QLKWorkspace? { get }
    
    var IsConnected : Bool { get }
}