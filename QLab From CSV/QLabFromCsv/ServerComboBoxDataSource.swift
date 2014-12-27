//
//  ServerComboBoxDataSource.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 27/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class ServerComboBoxDataSource : NSObject, NSComboBoxDataSource {
    private var _servers : [QLKServer] = []
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
    
    func setServers(servers : [QLKServer]) {
        _servers = servers
        _comboBox?.noteNumberOfItemsChanged()
    }
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        let server = _servers[index]
        return "\(server.name) (\(server.host))"
    }
    
    func numberOfItemsInComboBox(aComboBox : NSComboBox) -> Int {
        return _servers.count
    }
    
    func getSelectedServer() -> QLKServer? {
        if let index = _comboBox?.indexOfSelectedItem {
            return index >= 0 ? _servers[index] : nil
        } else {
            return nil
        }
    }
}