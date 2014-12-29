//
//  CueCreator.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 28/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class CueQLabConnector {
    private let _workspace : QLKWorkspace
    
    init(workspace : QLKWorkspace) {
        _workspace = workspace
    }
    func appendCues(var cues : [Cue], completion : () -> ()) {
        if cues.isEmpty {
            completion()
        } else {
            var nextCue = cues.removeAtIndex(0)
            appendCue(nextCue, {
                println("Created \(nextCue)")
                self.appendCues(cues, completion)
            })
        }
    }
    func appendCue(cue : Cue, completion : () -> ()) {
        // TODO: Handle cues correctly
        _workspace.sendMessage("group", toAddress:"/new", block: {
            (data : AnyObject!) in
            let uid = data as String
            println("Created cue with UID=\(uid)")
            completion()
        })
    }
}