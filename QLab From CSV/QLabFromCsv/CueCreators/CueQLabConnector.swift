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
    private let _startCueConnector : StartCueQLabConnector
    
    init(workspace : QLKWorkspace) {
        _workspace = workspace
        
        _groupCueConnector = GroupCueQLabConnector(workspace: workspace)
        _startCueConnector = StartCueQLabConnector(workspace: workspace)
        
        _groupCueConnector.cueConnector = self
    }
    func appendCues(var cues : [Cue], completion : (uids : [String]) -> ()) {
        if cues.isEmpty {
            completion(uids: [])
        } else {
            var nextCue = cues.removeAtIndex(0)
            appendCue(nextCue) {
                (uid : String) in
                println("Created \(nextCue)")
                self.appendCues(cues) {
                    (uids : [String]) in
                    completion(uids: [uid] + uids)
                }
            }
        }
    }
    func appendCue(cue : Cue, completion : (uid : String) -> ()) {
        if (cue is GroupCue) {
            _groupCueConnector.appendCue(cue as GroupCue, completion: completion)
        } else if (cue is StartCue) {
            _startCueConnector.appendCue(cue as StartCue, completion: completion)
        } else {
            println("Unknown cue type for \(cue)")
        }
    }
}