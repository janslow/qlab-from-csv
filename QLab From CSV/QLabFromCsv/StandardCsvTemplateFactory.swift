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
    
    public static func build(columnNames : [String], issues : ParseIssueAcceptor) -> CsvTemplate? {
        var remainingColumnNames = columnNames
        if let index = remainingColumnNames.indexOf(ID_COLUMN) {
            remainingColumnNames.removeAtIndex(index)
        } else {
            issues.add(IssueSeverity.FATAL, line: 1, cause: nil, code: "MISSING_HEADER_COLUMN", details: "Missing ID column : \(ID_COLUMN)")
            return nil
        }
        
        let hasCommentColumn : Bool
        if let index = remainingColumnNames.indexOf(COMMENT_COLUMN) {
            hasCommentColumn = true
            remainingColumnNames.removeAtIndex(index)
        } else {
            hasCommentColumn = false
        }
        
        let hasPageColumn : Bool
        if let index = remainingColumnNames.indexOf(PAGE_COLUMN) {
            hasPageColumn = true
            remainingColumnNames.removeAtIndex(index)
        } else {
            hasPageColumn = false
        }
        
        var columnToCueParserMap = [String: CueParser]()
        for columnName in remainingColumnNames {
            if let cueParser = buildCueParser(columnName, issues: issues) {
                columnToCueParserMap[columnName] = cueParser
            }
        }
        
        return CsvTemplateImpl(idColumn: ID_COLUMN, columnToCueParserMap: columnToCueParserMap, commentColumn: hasCommentColumn ? COMMENT_COLUMN : nil, pageColumn: hasPageColumn ? PAGE_COLUMN : nil)
    }
    
    private static func buildCueParser(columnName : String, issues : ParseIssueAcceptor) -> CueParser? {
        switch columnName {
        case "Sound", "SFX", "Video":
            let prefix = columnName.substringToIndex(columnName.startIndex)
            return buildStartCueParser(prefix)
        case "LX":
            return buildLXCueParser()
        default:
            break
        }
        
        issues.add(IssueSeverity.WARN, line: 1, cause: columnName, code: "UNKNOWN_COLUMN_NAME", details: "Unable to create CueParser for column.")
        return nil
    }
    
    private static func buildLXCueParser() -> CueParser {
        return {
            (parts : [String], preWait : Float, issues : ParseIssueAcceptor, line : Int) -> [Cue] in
            if (parts.count < 1) {
                issues.add(IssueSeverity.ERROR, line: line, cause: nil, code: "MISSING_LX_NUMBER", details: "The LX cue number is missing.")
                return []
            }
            var i = 0
            let cue = ETCEosGoCue(lxNumber: parts[i++], preWait: preWait)
            if i < parts.count && parts[i].hasPrefix("L") {
                var cueListString = parts[i++]
                cueListString = cueListString.substringFromIndex(cueListString.startIndex.advancedBy(1)) as String
                
                cue.lxCueList = Int((cueListString.substringFromIndex(cueListString.startIndex.advancedBy(1)) as NSString).intValue)
            }
            if i < parts.count && parts[i].hasPrefix("P") {
                let patchString = parts[i++]
                cue.patch = Int((patchString.substringFromIndex(patchString.startIndex.advancedBy(1)) as NSString).intValue)
            }
            return [cue]
        }
    }
    
    private static func buildStartCueParser(prefix : String) -> CueParser {
        return {
            (parts : [String], preWait : Float, issues : ParseIssueAcceptor, line : Int) -> [Cue] in
            if (parts.count < 1) {
                issues.add(IssueSeverity.ERROR, line: line, cause: nil, code: "MISSING_LX_NUMBER", details: "The cue number is missing.")
                return []
            }
            return [StartCue(targetNumber: prefix + parts[0], preWait: preWait)]
        }
    }
}