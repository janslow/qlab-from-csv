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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true)
        log.info("Launched Application")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

