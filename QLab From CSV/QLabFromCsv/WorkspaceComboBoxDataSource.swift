//
//  WorkspaceComboBoxDataSource.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 27/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class WorkspaceComboBoxDataSource : NSObject, NSComboBoxDataSource {
    private var _workspaces : [QLKWorkspace] = []
    private var _comboBox : NSComboBox? = nil
    
    var comboBox : NSComboBox? {
        get {
            return _comboBox
        }
    }
    
    func bindToComboBox(comboBox : NSComboBox) {
        _comboBox = comboBox
        if _comboBox != nil {
            _comboBox!.dataSource = self
            _comboBox!.reloadData()
        }
    }
    
    func setWorkspaces(workspaces : [QLKWorkspace]) {
        _workspaces = workspaces
        _comboBox?.noteNumberOfItemsChanged()
    }
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        return _workspaces[index].name
    }
    
    func numberOfItemsInComboBox(aComboBox : NSComboBox) -> Int {
        return _workspaces.count
    }
    
    func getSelectedWorkspace() -> QLKWorkspace? {
        if let index = _comboBox?.indexOfSelectedItem {
            return index >= 0 ? _workspaces[index] : nil
        } else {
            return nil
        }
    }
}