//
//  XCGLoggerNSLogDestination.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 03/02/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

// - A log destination that outputs log details to the System log.
public class NSLogDestination : XCGLogDestinationProtocol, CustomDebugStringConvertible {
    public var owner: XCGLogger
    public var identifier: String
    public var outputLogLevel: XCGLogger.LogLevel = .Warning
    
    public var showLogLevel: Bool = true
    
    public init(owner: XCGLogger, identifier: String = "") {
        self.owner = owner
        self.identifier = identifier
    }
    
    public func processLogDetails(logDetails: XCGLogDetails) {
        processInternalLogDetails(logDetails)
    }
    
    public func processInternalLogDetails(logDetails: XCGLogDetails) {
        var extendedDetails: String = ""
        if showLogLevel {
            extendedDetails += "[" + logDetails.logLevel.description() + "]"
        }
        
        var fullLogMessage: String =  "\(extendedDetails) \(logDetails.logMessage)"
        
        dispatch_async(XCGLogger.logQueue) {
            NSLog(fullLogMessage)
        }
    }
    
    // MARK: - Misc methods
    public func isEnabledForLogLevel (logLevel: XCGLogger.LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }
    
    // MARK: - DebugPrintable
    public var debugDescription: String {
        get {
            return "NSLogDestination: \(identifier) - LogLevel: \(outputLogLevel.description()) showLogLevel: \(showLogLevel)"
        }
    }
}