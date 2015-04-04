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
    private let _oscCueConnector : OscCueQLabConnector
    private let _scriptCueConnector : ScriptCueQLabConnector
    
    init(workspace : QLKWorkspace) {
        _workspace = workspace
        
        _groupCueConnector = GroupCueQLabConnector(workspace: workspace)
        _startCueConnector = StartCueQLabConnector(workspace: workspace)
        _oscCueConnector = OscCueQLabConnector(workspace: workspace)
        _scriptCueConnector = ScriptCueQLabConnector(workspace: workspace)
        
        _groupCueConnector.cueConnector = self
    }
    func appendCues(var cues : [Cue], completion : (uids : [String]) -> ()) {
        if cues.isEmpty {
            completion(uids: [])
        } else {
            var nextCue = cues.removeAtIndex(0)
            appendCue(nextCue) {
                (uid : String) in
                log.debug("Created \(nextCue) with UID \(uid)")
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
        } else if (cue is OscCue) {
            _oscCueConnector.appendCue(cue as OscCue, completion: completion)
        } else if (cue is ScriptCue) {
            _scriptCueConnector.appendCue(cue as ScriptCue, completion: completion)
        } else {
            log.error("No QLab connector for \(cue)")
        }
    }
}