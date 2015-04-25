//
//  X32CsvTemplateFactory.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public class X32CsvTemplateFactory {
    private static let ID_COLUMN = "QLab"
    private static let COMMENT_COLUMN = "Comment"
    private static let PAGE_COLUMN = "Page"
    
    private static let MUTE_COLUMN = "Mute"
    
    public static func build(columnNames : [String], issues : ParseIssueAcceptor) -> CsvTemplate? {
        var remainingColumnNames = columnNames
        if let index = find(remainingColumnNames, ID_COLUMN) {
            remainingColumnNames.removeAtIndex(index)
        } else {
            issues.add(IssueSeverity.FATAL, line: 1, cause: nil, code: "MISSING_HEADER_COLUMN", details: "Missing ID column : \(ID_COLUMN)")
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
            if let cueParser = buildCueParser(columnName, issues: issues) {
                columnToCueParserMap[columnName] = cueParser
            }
        }
        
        return CsvTemplateImpl(idColumn: ID_COLUMN, columnToCueParserMap: columnToCueParserMap, commentColumn: hasCommentColumn ? COMMENT_COLUMN : nil, pageColumn: hasPageColumn ? PAGE_COLUMN : nil)
    }
    
    private static func buildCueParser(columnName : String, issues : ParseIssueAcceptor) -> CueParser? {
        switch columnName {
        case MUTE_COLUMN:
            return buildMuteCueParser()
        default:
            break
        }
        
        issues.add(IssueSeverity.WARN, line: 1, cause: columnName, code: "UNKNOWN_COLUMN_NAME", details: "Unable to create CueParser for column.")
        return nil
    }
    
    private static func buildMuteCueParser() -> CueParser {
        return {
            (parts : [String], preWait : Float, issues : ParseIssueAcceptor, line : Int) -> [Cue] in
            if parts.count < 1 {
                issues.add(IssueSeverity.ERROR, line: line, cause: nil, code: "MISSING_CHANNEL", details: "The channel number to mute/unassign is missing")
                return []
            }
            if parts.count > 1 {
                issues.add(IssueSeverity.WARN, line: line, cause: "\(parts)", code: "EXTRA_PARAMETERS", details: "Only the channel number was expected")
            }
            if let channel = parts[0].toInt() {
                return [
                    X32AssignChannelToDCACue(channel: channel, dca: nil, preWait: preWait),
                    X32SetChannelMixOnCue(channel: channel, on: false, preWait: preWait)
                ]
            } else {
                issues.add(IssueSeverity.ERROR, line: line, cause: parts[0], code: "INVALID_CHANNEL", details: "The channel must be an integer value")
                return []
            }
        }
    }
}