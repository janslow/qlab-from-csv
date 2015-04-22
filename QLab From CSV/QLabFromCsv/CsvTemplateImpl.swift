
//
//  CsvTemplateImpl.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-22.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

class CsvTemplateImpl : CsvTemplate {
    init(idColumn : String, columnToCueParserMap : Dictionary<String, CueParser>, commentColumn : String?, pageColumn : String?) {
        IdColumn = idColumn
        ColumnToCueParserMap = columnToCueParserMap
        CommentColumn = commentColumn
        PageColumn = pageColumn
    }
    
    let IdColumn : String
    
    let ColumnToCueParserMap : Dictionary<String, CueParser>
    
    let CommentColumn : String?
    
    let PageColumn : String?
}