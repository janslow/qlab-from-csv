//
//  TabViewControllerScene.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 12/02/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public protocol MasterViewController {
    var QLabController : QLabViewController { get }
    var CuesController : CuesViewController { get }
    
    func fireCheckValid()
    func append()
}