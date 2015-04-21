//
//  ConnectionState.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-21.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

enum ConnectionState {
    case NotConnected
    case Connecting(QLKWorkspace)
    case Connected(QLKWorkspace)
}