//
//  LxGoCueQLabConnector.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 17/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class OscUdpCueQLabConnector : CueQLabConnectorBase {

    override init(workspace : QLKWorkspace) {
        super.init(workspace: workspace)
    }
    
    func appendCue(cue : OscUdpCue, completion : (uid : String) -> ()) {
        createCue("osc", cue: cue as Cue) {
            (uid : String) in
            self.setAttribute(uid, attribute: "messageType", value: 3) {
                self.setAttribute(uid, attribute: "udpString", value: cue.udpString) {
                    completion(uid: uid)
                }
            }
        }
    }
}