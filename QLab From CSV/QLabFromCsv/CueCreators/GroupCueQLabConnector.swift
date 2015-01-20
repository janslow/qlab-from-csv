//
//  GroupCueQLabConnector.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 29/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class GroupCueQLabConnector : CueQLabConnectorBase {
    internal var cueConnector : CueQLabConnector?
    
    override init(workspace : QLKWorkspace) {
        super.init(workspace: workspace)
    }
    
    func appendCue(cue : GroupCue, completion : (uid : String) -> ()) {
        appendChildren(cue.children) {
            (uids : [String]) in
            self.selectCues(uids) {
                self.createCue("group", cue: cue as Cue) {
                    (uid : String) in
                    completion(uid: uid)
                }
            }
        }
        
    }
    
    private func appendChildren(children : [Cue], completion : (uids : [String]) -> ()) {
        cueConnector!.appendCues(children) {
            (uids : [String]) in
            println("Created children: \(uids)")
            completion(uids: uids)
        }
    }
    
    private func selectCues(uids : [String], completion : () -> ()) {
        let uidsString = ",".join(uids)
        self._workspace.sendMessage(nil, toAddress:"/select_id/\(uidsString)") {
            (data : AnyObject!) in
            println("SELECT WHERE cue.uid IN \(uids) RESPONSE \(data)")
            completion()
        }
    }
}