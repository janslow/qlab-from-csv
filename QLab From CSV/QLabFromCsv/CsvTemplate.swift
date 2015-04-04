//
//  CueCategories.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-03.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public protocol CsvTemplate {
    var categories : Dictionary<String, ([String], Float) -> Cue> { get }
    var idCategory : String { get }
    var pageCategory : String? { get }
    var commentCategory : String? { get }
}