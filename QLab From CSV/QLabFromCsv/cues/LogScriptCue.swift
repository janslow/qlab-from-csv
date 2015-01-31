
//
//  LogScriptCue.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 31/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class LogScriptCue : ScriptCue, Printable {
    var cueNumber : String? {
        return nil
    }
    var cueName : String {
        return "Log to \(logFile)"
    }
    var description : String {
        return "Log"
    }
    var preWait : Float
    var script : String {
        return "do shell script \"echo \\\"`date '+%Y-%m-%d %H:%M:%S'`,\(logId)\\\" >> \\\"\(logFile)\\\"\""
    }
    var logId : String
    var logFile : String
    
    init(logId : String, logFile : String, preWait : Float) {
        self.logId = logId
        self.logFile = logFile
        self.preWait = preWait
    }
}