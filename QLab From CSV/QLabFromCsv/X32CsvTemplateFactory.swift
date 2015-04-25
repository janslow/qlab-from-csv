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
    
    private static func buildMuteCueParser() -> CueParser {
        return {
            (parts : [String], preWait : Float) -> Cue in
            let channel = parts[0].toInt()!
            return self.createAssignToDCACue(channel, dca: 0, preWait: preWait)
        }
    }
    
    private static func createAssignToDCACue(channel : Int, dca : Int, preWait : Float) -> OscCustomCue {
        let channelString = String(format: "%02d", channel)
        return OscCustomCueImpl(customString: "/ch/\(channelString)/grp/\(dca)", preWait: preWait)
    }
}