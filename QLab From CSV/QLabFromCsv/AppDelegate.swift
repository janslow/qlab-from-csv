//
//  AppDelegate.swift
//  QLabFromCsv
//
//  Created by Jay Anslow on 24/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let csvParser = CsvParser.csv()
        let csvPath = "/Users/janslow/dev/qlab_from_csv/sample_cues.csv"
        let csv = csvParser.parseFromFile(csvPath)!
        
        let rowParser = RowParser()
        let cues = rowParser.load(csv.rows)
        println(cues)
        
        var complete = false
        
        let server = QLKServer(host: "localhost", port: 53000)
        server.refreshWorkspacesWithCompletion({
            (obj : [AnyObject]!) -> () in
            println(obj)
            println(server.workspaces)
            complete = true
        })
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

