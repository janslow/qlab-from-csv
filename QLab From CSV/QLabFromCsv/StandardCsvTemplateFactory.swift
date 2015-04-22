//
//  StandardCsvTemplateFactoryImpl.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-22.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public class StandardCsvTemplateFactory {
    private static let ID_COLUMN = "QLab"
    private static let COMMENT_COLUMN = "Comment"
    private static let PAGE_COLUMN = "Page"
    
    public static func build(columnNames : [String]) -> CsvTemplate? {
        var remainingColumnNames = columnNames
        if let index = find(remainingColumnNames, ID_COLUMN) {
            remainingColumnNames.removeAtIndex(index)
        } else {
            log.error("Missing ID column : \(ID_COLUMN)")
            return nil
        }
        
        let hasCommentColumn : Bool
        if let index = find(remainingColumnNames, COMMENT_COLUMN) {
            hasCommentColumn = true
            remainingColumnNames.removeAtIndex(index)
        } else {
            hasCommentColumn = false
        }
        
        let hasPageColumn : Bool
        if let index = find(remainingColumnNames, PAGE_COLUMN) {
            hasPageColumn = true
            remainingColumnNames.removeAtIndex(index)
        } else {
            hasPageColumn = false
        }
        
        var columnToCueParserMap = [String: CueParser]()
        for columnName in remainingColumnNames {
            if let cueParser = buildCueParser(columnName) {
                columnToCueParserMap[columnName] = cueParser
            } else {
                log.error("Error converting column \(columnName)")
            }
        }
        
        return CsvTemplateImpl(idColumn: ID_COLUMN, columnToCueParserMap: columnToCueParserMap, commentColumn: hasCommentColumn ? COMMENT_COLUMN : nil, pageColumn: hasPageColumn ? PAGE_COLUMN : nil)
    }
    
    private static func buildCueParser(columnName : String) -> CueParser? {
        switch columnName {
        case "Sound", "SFX", "Video":
            let prefix = columnName.substringToIndex(columnName.startIndex)
            return buildStartCueParser(prefix)
        case "LX":
            return buildLXCueParser()
        default:
            break
        }
        
        return nil
    }
    
    private static func buildLXCueParser() -> CueParser {
        return {
            (parts : [String], preWait : Float) -> Cue in
            var i = 0
            let cue = LxGoCue(lxNumber: parts[i++], preWait: preWait)
            if i < parts.count && parts[i].hasPrefix("L") {
                let cueListString = parts[i++]
                cue.lxCueList = Int((cueListString.substringFromIndex(advance(cueListString.startIndex, 1)) as NSString).intValue)
            }
            if i < parts.count && parts[i].hasPrefix("P") {
                let patchString = parts[i++]
                cue.patch = Int((patchString.substringFromIndex(advance(patchString.startIndex, 1)) as NSString).intValue)
            }
            return cue
        }
    }
    
    private static func buildStartCueParser(prefix : String) -> CueParser {
        return {
            (parts : [String], preWait : Float) -> Cue in
            return StartCue(targetNumber: prefix + parts[0], preWait: preWait)
        }
    }
}