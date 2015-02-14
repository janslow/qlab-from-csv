//
//  AppDelegate.swift
//  QLabFromCsv
//
//  Created by Jay Anslow on 24/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Cocoa
import Foundation

let log = XCGLogger.defaultInstance()
var MAIN_VIEW_CONTROLLER : MasterViewController?
var APP_DELEGATE : AppDelegate?

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate {

    public func setIsRunAllowed(allowed : Bool) {
    }
    
    override init() {
        super.init()
        APP_DELEGATE = self
    }
    
    public func applicationDidFinishLaunching(aNotification: NSNotification) {
        setUpLogging()
        
        log.info("App has finished launching")
    }

    public func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    private func setUpLogging() {
        log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true)
        let nsLogDestination = NSLogDestination(owner: log, identifier: "AppDelegate")
        log.addLogDestination(nsLogDestination)
    }
}

