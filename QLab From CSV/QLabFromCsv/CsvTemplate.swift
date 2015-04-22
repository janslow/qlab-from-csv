//
//  CueCategories.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-03.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public typealias CueParser = (parts : [String], preWait : Float) -> Cue

public protocol CsvTemplate {
    var ColumnToCueParserMap : Dictionary<String, CueParser> { get }
    var IdColumn : String { get }
    var PageColumn : String? { get }
    var CommentColumn : String? { get }
}