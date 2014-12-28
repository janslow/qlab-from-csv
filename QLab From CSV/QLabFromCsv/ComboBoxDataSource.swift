
//
//  ComboBoxDataSource.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 28/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class ComboBoxDataSource : NSObject, NSComboBoxDataSource {
    internal var _items : [AnyObject] = []
    internal var _comboBox : NSComboBox? = nil
    
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
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        let item : AnyObject = _items[index]
        return itemToString(item)
    }
    
    func itemToString(item : AnyObject) -> String {
        return "\(item)"
    }
    
    func setItems(items : [AnyObject]) {
        _items = items
        _comboBox?.noteNumberOfItemsChanged()
    }
    
    func numberOfItemsInComboBox(aComboBox : NSComboBox) -> Int {
        return _items.count
    }
    
    func getSelectedItem() -> AnyObject? {
        if let index = _comboBox?.indexOfSelectedItem {
            return index >= 0 ? _items[index] : nil
        } else {
            return nil
        }
    }
}