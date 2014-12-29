//
//  GroupCueQLabConnector.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 29/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class CueQLabConnectorBase {
    private let _workspace : QLKWorkspace
    
    init(workspace : QLKWorkspace) {
        _workspace = workspace
    }
    
    private func createCue(cueType : String, cue : Cue, completion : (uid : String) -> ()) {
        _workspace.sendMessage(cueType, toAddress:"/new", block: {
            (data : AnyObject!) in
            let uid = data as String
            println("INSERT \(cueType) cue RESPONSE uid = \(uid)")
            let number = cue.cueNumber ?? ""
            self._workspace.sendMessage(number, toAddress:"/cue_id/\(uid)/number") {
                (data : AnyObject!) in
                println("UPDATE cue.number = \(number) WHERE cue.uid = \(uid) RESPONSE \(data)")
                let name = cue.cueName ?? ""
                self._workspace.sendMessage(name, toAddress:"/cue_id/\(uid)/name") {
                    (data : AnyObject!) in
                    println("UPDATE cue.name = \(name) WHERE cue.uid = \(uid) RESPONSE \(data)")
                    completion(uid: uid)
                }
            }
        })
    }
}
class GroupCueQLabConnector : CueQLabConnectorBase {
    override init(workspace : QLKWorkspace) {
        super.init(workspace: workspace)
    }
    func appendCue(cue : GroupCue, completion : () -> ()) {
        createCue("group", cue: cue as Cue) {
            (uid : String) in
            completion()
        }
    }
}