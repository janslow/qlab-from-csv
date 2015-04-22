//
//  WorkspaceComboBoxDataSource.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 27/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class WorkspaceComboBoxDataSource : ComboBoxDataSource {
    override func itemToString(item : AnyObject) -> String {
        let workspace = item as! QLKWorkspace
        return workspace.name
    }
    
    func getSelectedWorkspace() -> QLKWorkspace? {
        return getSelectedItem() as? QLKWorkspace
    }
}