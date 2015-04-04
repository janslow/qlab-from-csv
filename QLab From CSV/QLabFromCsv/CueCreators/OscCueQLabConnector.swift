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
                var messageType : Int
                var messageAttribute : String
                var message : String
                if let oscCustomCue = cue as? OscCustomCue {
                    messageType = 2
                    messageAttribute = "customString"
                    message = oscCustomCue.customString
                } else if let oscUdpCue = cue as? OscUdpCue {
                    messageType = 3
                    messageAttribute = "udpString"
                    message = oscUdpCue.udpString
                } else {
                    log.error("OscCueQLabConnector: Unknown OSC type for \(cue)")
                    completion(uid: uid)
                    return
                }
                self.setOscDetails(uid, messageType: messageType, messageAttribute: messageAttribute, message: message, completion)
            }
        }
    }
    
    func setOscDetails(uid : String, messageType : Int, messageAttribute : String, message : String, completion : (uid : String) -> ()) {
        self.setAttribute(uid, attribute: "messageType", value: messageType) {
            self.setAttribute(uid, attribute: messageAttribute, value: message) {
                completion(uid: uid)
            }
        }
    }
}