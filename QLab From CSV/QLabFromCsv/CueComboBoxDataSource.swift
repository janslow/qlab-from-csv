//
//  CueComboBoxDataSource.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 28/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class CueComboBoxDataSource : ComboBoxDataSource {
    private let _showNumber : Bool
    
    init(showNumber : Bool) {
        _showNumber = showNumber
    }
    
    override func itemToString(item : AnyObject) -> String {
        let cue = item as! QLKCue
        
        if _showNumber {
            let number = cue.number ?? "?"
            if cue.name != nil {
                return "\(number) (\(cue.name!))"
            } else {
                return number
            }
        } else {
            return cue.name ?? "?"
        }
    }
    
    func getSelectedCue() -> QLKCue? {
        return getSelectedItem() as? QLKCue
    }
}