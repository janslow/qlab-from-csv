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
            self.updateMessageType(uid, messageType: 3) {
                self.updateUdpString(uid, udpString: cue.udpString) {
                    completion(uid: uid)
                }
            }
        }
    }
    
    private func updateMessageType(uid : String, messageType : Int, completion : () -> ()) {
        self._workspace.sendMessage(messageType, toAddress:"/cue_id/\(uid)/messageType") {
            (data : AnyObject!) in
            println("UPDATE cue.messageType = \"\(messageType)\" WHERE cue.uid = \(uid) RESPONSE \(data)")
            completion()
        }
    }
    
    private func updateUdpString(uid : String, udpString : String, completion : () -> ()) {
        self._workspace.sendMessage(udpString, toAddress:"/cue_id/\(uid)/udpString") {
            (data : AnyObject!) in
            println("UPDATE cue.udpString = \"\(udpString)\" WHERE cue.uid = \(uid) RESPONSE \(data)")
            completion()
        }
    }
}