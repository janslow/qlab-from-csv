//
//  StartCueQLabConnector.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 17/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class StartCueQLabConnector : CueQLabConnectorBase {
    override init(workspace : QLKWorkspace) {
        super.init(workspace: workspace)
    }
    func appendCue(cue : StartCue, completion : (uid : String) -> ()) {
        createCue("start", cue: cue as Cue) {
            (uid : String) in
            self.updateTargetCue(uid, targetNumber: cue.targetNumber) {
                completion(uid: uid)
            }
        }
    }
    
    private func updateTargetCue(uid : String, targetNumber : String, completion : () -> ()) {
        self._workspace.sendMessage(targetNumber, toAddress:"/cue_id/\(uid)/cueTargetNumber") {
            (data : AnyObject!) in
            println("UPDATE cue.cueTargetNumber = \"\(targetNumber)\" WHERE cue.uid = \(uid) RESPONSE \(data)")
            completion()
        }
    }
}