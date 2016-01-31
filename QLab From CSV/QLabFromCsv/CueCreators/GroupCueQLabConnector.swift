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
            // Workaround to insert a temporary sub-cue if there is only one real sub-cue.
            if uids.count != 1 {
                self.selectCues(uids) {
                    self.createGroupCueWithMode(cue) {
                        (uid : String) in
                        completion(uid: uid)
                    }
                }
            } else {
                self.withTemporaryCue() {
                    (tempUid : String, deleteTemporaryCue : (() -> ()) -> ()) in
                    self.selectCues(uids + [tempUid]) {
                        self.createGroupCueWithMode(cue) {
                            (uid : String) in
                            deleteTemporaryCue() {
                                completion(uid: uid)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func createGroupCueWithMode(cue : Cue, completion : (uid : String) -> ()) {
        self.createCue("group", cue: cue as Cue) {
            (uid : String) in
            self.setAttribute(uid, attribute: "mode", value: 3) {
                completion(uid: uid)
            }
        }
    }

    private func withTemporaryCue(created : (tempUid : String, deleteTemporaryCue : (() -> ()) -> ()) -> ()) {
        self.createCue("group", completion: {
        (uid : String) in
            self.setAttribute(uid, attribute: "number", value: "") {
                created(tempUid: uid) {
                    (completion : () -> ()) in
                    self.deleteCue(uid) {
                        completion()
                    }
                }
            }
        })
    }

    private func appendChildren(children : [Cue], completion : (uids : [String]) -> ()) {
        cueConnector!.appendCues(children) {
            (uids : [String]) in
            log.debug("Created children: \(uids)")
            completion(uids: uids)
        }
    }
    
    private func selectCues(uids : [String], completion : () -> ()) {
        let uidsString = uids.joinWithSeparator(",")
        self._workspace.sendMessage(nil, toAddress:"/select_id/\(uidsString)") {
            (data : AnyObject!) in
            log.debug("SELECT WHERE cue.uid IN \(uids) RESPONSE \(data)")
            completion()
        }
    }
    
    private func deleteCue(uid : String, completion : () -> ()) {
        self._workspace.sendMessage(nil, toAddress:"/delete_id/\(uid)") {
            (data : AnyObject!) in
            log.debug("DELETE WHERE cue.uid IN \(uid) RESPONSE \(data)")
            completion()
        }
    }
}