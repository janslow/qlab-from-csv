
//
//  ParseIssue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-04.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public protocol ParseIssue : Printable {
    var severity : IssueSeverity { get }
    var line : Int { get }
    var cause : String? { get }
    var code : String { get }
    var details : String { get }
}