
//
//  CueQLabConnectorBase.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 17/01/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class CueQLabConnectorBase {
    internal let _workspace : QLKWorkspace
    
    internal init(workspace : QLKWorkspace) {
        _workspace = workspace
    }
    
    internal func createCue(cueType : String, cue nillableCue : Cue? = nil, completion : (uid : String) -> ()) {
        _workspace.sendMessage(cueType, toAddress:"/new", block: {
            (data : AnyObject!) in
            let uid = data as String
            println("INSERT \(cueType) cue RESPONSE uid = \(uid)")
            
            if let cue = nillableCue {
                self.setAttribute(uid, attribute: "number", nillableValue: cue.cueNumber, defaultValue: "") {
                    self.setAttribute(uid, attribute: "name", nillableValue: cue.cueName) {
                        self.setAttribute(uid, attribute: "preWait", nillableValue: cue.preWait > 0.0 ? cue.preWait : nil) {
                            completion(uid: uid)
                        }
                    }
                }
            } else {
                completion(uid: uid)
            }
        })
    }
    
    // Set the attribute of a cue.
    internal func setAttribute(uid : String, attribute : String, value : AnyObject, completion : () -> ()) {
        self._workspace.sendMessage(value, toAddress:"/cue_id/\(uid)/\(attribute)") {
            (data : AnyObject!) in
            let valueString = value is String ? "\"\(value)\"" : "\(value)"
            println("UPDATE cue.\(attribute) = \(valueString) WHERE cue.uid = \(uid) RESPONSE \(data)")
            completion()
        }
    }
    
    // Set the attribute of a cue, using a default value if the provided value is nil.
    internal func setAttribute(uid : String, attribute : String, nillableValue : AnyObject?, defaultValue : AnyObject, completion : () -> ()) {
        setAttribute(uid, attribute: attribute, value: nillableValue ?? defaultValue, completion)
    }
    
    // Set the attribute of a cue, iff the value is non-nil.
    internal func setAttribute(uid : String, attribute : String, nillableValue : AnyObject?, completion : () -> ()) {
        if let value : AnyObject = nillableValue {
            setAttribute(uid, attribute: attribute, value: value, completion)
        } else {
            completion()
        }
    }
}