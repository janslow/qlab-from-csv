//
//  ScriptCueQLabConnector.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 31/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class ScriptCueQLabConnector : CueQLabConnectorBase {
    
    override init(workspace : QLKWorkspace) {
        super.init(workspace: workspace)
    }
    
    func appendCue(cue : ScriptCue, completion : (uid : String) -> ()) {
        createCue("script", cue: cue as Cue) {
            (uid : String) in
            self.setAttribute(uid, attribute: "scriptSource", value: cue.script) {
                completion(uid: uid)
            }
        }
    }
}