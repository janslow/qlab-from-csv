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
    
    private let _groupCueConnector : GroupCueQLabConnector
    
    init(workspace : QLKWorkspace) {
        _workspace = workspace
        _groupCueConnector = GroupCueQLabConnector(workspace: workspace)
        
        _groupCueConnector.cueConnector = self
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
        if (cue is GroupCue) {
            _groupCueConnector.appendCue(cue as GroupCue, completion: completion)
        } else {
            println("Unknown cue type \(cue)")
        }
    }
}