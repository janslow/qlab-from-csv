//
//  XCGLoggerNSLogDestination.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 03/02/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

// - A standard log destination that outputs log details to the System log.
public class NSLogDestination : XCGLogDestinationProtocol, DebugPrintable {
    public var owner: XCGLogger
    public var identifier: String
    public var outputLogLevel: XCGLogger.LogLevel = .Warning
    
    public var showLogLevel: Bool = true
    public var dateFormatter: NSDateFormatter? {
        return NSThread.dateFormatter("yyyy-MM-dd HH:mm:ss.SSS")
    }
    
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
            extendedDetails += "[" + logDetails.logLevel.description() + "] "
        }
        
        var formattedDate: String = logDetails.date.description
        if let unwrappedDataFormatter = dateFormatter {
            formattedDate = unwrappedDataFormatter.stringFromDate(logDetails.date)
        }
        
        var fullLogMessage: String =  "\(formattedDate) \(extendedDetails): \(logDetails.logMessage)\n"
        
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