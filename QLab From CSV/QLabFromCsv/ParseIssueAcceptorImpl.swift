//
//  ParseIssueAcceptor.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-04.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public class ParseIssueAcceptorImpl : ParseIssueAcceptor {
    private class ParseIssueImpl : ParseIssue {
        var Severity : IssueSeverity
        var Line : Int?
        var Cause : String?
        var Code : String
        var Details : String
        
        init(severity : IssueSeverity, line : Int?, cause : String?, code : String, details : String) {
            Severity = severity
            Line = line
            Cause = cause
            Code = code
            Details = details
        }
        
        var description : String {
            get {
                var s = "\(Severity) parse issue"
                if let line = Line {
                    s += " at line \(line)"
                }
                if let cause = Cause {
                    s += " (\"\(cause)\")"
                }
                s += ": \(Code) (\(Details))"
                return s
            }
        }
    }
    
    public var Issues : [ParseIssue] {
        get {
            return _issues
        }
    }
    
    public var HasFatalErrors : Bool {
        get {
            return !self.getBySeverity(IssueSeverity.FATAL).isEmpty
        }
    }
    
    private var _issues : [ParseIssue] = []
    
    public func add(issue : ParseIssue) {
        switch (issue.Severity) {
        case IssueSeverity.FATAL, IssueSeverity.ERROR:
            log.error(issue.description)
            break
        case IssueSeverity.WARN:
            log.warning(issue.description)
            break
        }
        _issues.append(issue)
    }
    
    public func add(severity : IssueSeverity, line : Int?, cause : String?, code : String, details : String) {
        self.add(ParseIssueImpl(severity: severity, line: line, cause: cause, code: code, details: details))
    }
    
    public func getBySeverity(severity : IssueSeverity) -> [ParseIssue] {
        return _issues.filter({
            (issue : ParseIssue) in
            issue.Severity == severity
        })
    }
}