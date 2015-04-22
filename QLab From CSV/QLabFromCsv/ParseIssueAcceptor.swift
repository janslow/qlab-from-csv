//
//  ParseIssueAcceptor.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-22.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public protocol ParseIssueAcceptor {
    var Issues : [ParseIssue] { get }
    
    var HasFatalErrors : Bool { get }
    
    var CurrentLine : Int { get }
    
    func add(issue : ParseIssue)
    func add(severity : IssueSeverity, line : Int, cause : String?, code : String, details : String)
    func add(severity : IssueSeverity, cause : String?, code : String, details : String)
    
    func getBySeverity(severity : IssueSeverity) -> [ParseIssue]
}