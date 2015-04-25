
//
//  ParseIssue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-04.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public protocol ParseIssue : Printable {
    var Severity : IssueSeverity { get }
    var Line : Int? { get }
    var Cause : String? { get }
    var Code : String { get }
    var Details : String { get }
}