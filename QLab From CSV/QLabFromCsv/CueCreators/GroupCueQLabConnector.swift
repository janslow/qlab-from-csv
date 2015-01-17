//
//  GroupCueQLabConnector.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 29/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

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