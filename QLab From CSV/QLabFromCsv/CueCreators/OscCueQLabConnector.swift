//
//  LxGoCueQLabConnector.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 17/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class OscCueQLabConnector : CueQLabConnectorBase {

    override init(workspace : QLKWorkspace) {
        super.init(workspace: workspace)
    }
    
    func appendCue(cue : OscCue, completion : (uid : String) -> ()) {
        createCue("osc", cue: cue as Cue) {
            (uid : String) in
            self.setAttribute(uid, attribute: "patch", value: cue.patch) {
                self.setAsUdpCue(cue as OscUdpCue, uid: uid) {
                    (uid: String) in
                    completion(uid: uid)
                }
            }
        }
    }
    
    func setAsUdpCue(cue : OscUdpCue, uid : String, completion : (uid : String) -> ()) {
        self.setAttribute(uid, attribute: "messageType", value: 3) {
            self.setAttribute(uid, attribute: "udpString", value: cue.udpString) {
                completion(uid: uid)
            }
        }
    }
}