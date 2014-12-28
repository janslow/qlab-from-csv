//
//  ServerComboBoxDataSource.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 27/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class ServerComboBoxDataSource : ComboBoxDataSource {
    override func itemToString(item : AnyObject) -> String {
        let server = item as QLKServer
        return "\(server.name) (\(server.host))"
    }
    
    func getSelectedServer() -> QLKServer? {
        return getSelectedItem() as? QLKServer
    }
}