
//
//  CueQLabConnectorBase.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 17/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class CueQLabConnectorBase {
    private let _workspace : QLKWorkspace
    
    internal init(workspace : QLKWorkspace) {
        _workspace = workspace
    }
    
    internal func createCue(cueType : String, cue : Cue, completion : (uid : String) -> ()) {
        _workspace.sendMessage(cueType, toAddress:"/new", block: {
            (data : AnyObject!) in
            let uid = data as String
            println("INSERT \(cueType) cue RESPONSE uid = \(uid)")
            
            self.updateNumber(uid, number: cue.cueNumber) {
                self.updateName(uid, name: cue.cueName) {
                    self.updatePreWait(uid, preWait: cue.preWait) {
                        completion(uid: uid)
                    }
                }
            }
        })
    }
    
    private func updateNumber(uid : String, number : String?, completion : () -> ()) {
        let numberNonNull = number ?? ""
        self._workspace.sendMessage(numberNonNull, toAddress:"/cue_id/\(uid)/number") {
            (data : AnyObject!) in
            println("UPDATE cue.number = \"\(numberNonNull)\" WHERE cue.uid = \(uid) RESPONSE \(data)")
            completion()
        }
    }
    
    private func updateName(uid : String, name : String?, completion : () -> ()) {
        if let nameNonNull = name {
            self._workspace.sendMessage(nameNonNull, toAddress:"/cue_id/\(uid)/name") {
                (data : AnyObject!) in
                println("UPDATE cue.name = \"\(nameNonNull)\" WHERE cue.uid = \(uid) RESPONSE \(data)")
                completion()
            }
        } else {
            completion()
        }
    }
    
    private func updatePreWait(uid : String, preWait : Float, completion : () -> ()) {
        if preWait > 0.0 {
            self._workspace.sendMessage(preWait, toAddress:"/cue_id/\(uid)/preWait") {
                (data : AnyObject!) in
                println("UPDATE cue.preWait = \(preWait) WHERE cue.uid = \(uid) RESPONSE \(data)")
                completion()
            }
        } else {
            completion()
        }
    }
}