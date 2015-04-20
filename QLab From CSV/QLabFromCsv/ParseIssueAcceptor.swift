//
//  ParseIssueAcceptor.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-04.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public class ParseIssueAcceptor {
    private class ParseIssueImpl : ParseIssue {
        var severity : IssueSeverity
        var line : Int
        var cause : String?
        var code : String
        var details : String
        
        init(severity : IssueSeverity, line : Int, cause : String?, code : String, details : String) {
            self.severity = severity
            self.line = line
            self.cause = cause
            self.code = code
            self.details = details
        }
        
        var description : String {
            get {
                var s = "\(self.severity) parse issue at line \(self.line)"
                if let cause = self.cause {
                    s += " (\"\(cause)\")"
                }
                s += ": \(self.code) (\(self.details))"
                return s
            }
        }
    }
    
    public var issues : [ParseIssue] {
        get {
            return _issues
        }
    }
    
    public var hasFatalErrors : Bool {
        get {
            return !self.getBySeverity(IssueSeverity.FATAL).isEmpty
        }
    }
    
    public var currentLine : Int = 0
    
    private var _issues : [ParseIssue] = []
    
    public func add(issue : ParseIssue) {
        switch (issue.severity) {
        case IssueSeverity.FATAL, IssueSeverity.ERROR:
            log.error(issue.description)
            break
        case IssueSeverity.WARN:
            log.warning(issue.description)
            break
        }
        _issues.append(issue)
    }
    
    public func add(severity : IssueSeverity, line : Int, cause : String?, code : String, details : String) {
        self.add(ParseIssueImpl(severity: severity, line: line, cause: cause, code: code, details: details))
    }
    
    public func add(severity : IssueSeverity, cause : String?, code : String, details : String) {
        self.add(severity, line: self.currentLine, cause: cause, code: code, details: details)
    }
    
    public func getBySeverity(severity : IssueSeverity) -> [ParseIssue] {
        return _issues.filter({
            (issue : ParseIssue) in
            issue.severity == severity
        })
    }
}