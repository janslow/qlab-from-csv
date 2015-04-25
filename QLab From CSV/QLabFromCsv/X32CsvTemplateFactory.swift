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
        
        if columnName.hasPrefix("VCA") || columnName.hasPrefix("DCA") {
            var dcaString = columnName.substringFromIndex(advance(columnName.startIndex, 3))
            dcaString = dcaString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if let dca = dcaString.toInt() {
                return buildDCACueParser(dca)
            } else {
                issues.add(IssueSeverity.ERROR, line: 1, cause: columnName, code: "INVALID_DCA_COLUMN_NAME", details: "Unable to parse DCA number from column name")
                return nil
            }
        }
        
        issues.add(IssueSeverity.WARN, line: 1, cause: columnName, code: "UNKNOWN_COLUMN_NAME", details: "Unable to create CueParser for column.")
        return nil
    }
    
    private static func buildMuteCueParser() -> CueParser {
        return {
            (parts : [String], preWait : Float, issues : ParseIssueAcceptor, line : Int) -> [Cue] in
            if parts.count < 1 {
                issues.add(IssueSeverity.ERROR, line: line, cause: nil, code: "MISSING_PARAMETERS", details: "The channel number to mute/unassign is missing")
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
    
    private static func buildDCACueParser(dca : Int) -> CueParser {
        return {
            (parts : [String], preWait : Float, issues : ParseIssueAcceptor, line : Int) -> [Cue] in
            if parts.count < 1 {
                issues.add(IssueSeverity.ERROR, line: line, cause: nil, code: "MISSING_PARAMETERS", details: "The DCA name is missing")
                return []
            }
            if parts[0] == "*" {
                return self.parseInactiveDCACue(dca, parts: parts, preWait: preWait, issues: issues, line: line)
            } else {
                return self.parseActiveDCACue(dca, parts: parts, preWait: preWait, issues: issues, line: line)
            }
        }
    }
    
    private static func parseInactiveDCACue(dca : Int, parts : [String], preWait : Float, issues : ParseIssueAcceptor, line : Int) -> [Cue] {
        if parts.count > 1 {
            issues.add(IssueSeverity.WARN, line: line, cause: "\(parts)", code: "EXTRA_PARAMETERS", details: "Only the DCA name was expected")
        }
        let cues : [Cue] = [
            X32SetDCANameCue(dca: dca, name: "", preWait: preWait),
            X32SetDCAColourCue(dca: dca, colour: X32Colour.OFF, preWait: preWait)
        ]
        let disableDCACue : Cue = GroupCue(cueNumber: "", comment: "Disable DCA \(dca)", page: nil, children: cues)
        return [disableDCACue]
    }
    
    private static func parseActiveDCACue(dca : Int, parts : [String], preWait : Float, issues : ParseIssueAcceptor, line : Int) -> [Cue] {
        if parts.count < 2 {
            issues.add(IssueSeverity.ERROR, line: line, cause: nil, code: "MISSING_PARAMETERS", details: "The DCA name and channel numbers are missing")
            return []
        }
        if parts.count > 2 {
            issues.add(IssueSeverity.WARN, line: line, cause: "\(parts)", code: "EXTRA_PARAMETERS", details: "Only the DCA name and channel numbers were expected")
        }
        let name = parts[0]
        let channels : [Int] = parts[1].componentsSeparatedByString("+").map({
            $0.toInt()
        }).filter({
            (channel : Int?) -> Bool in
            if (channel != nil) {
                issues.add(IssueSeverity.ERROR, line: line, cause: "\(parts)", code: "INVALID_DCA_CHANNELS", details: "Channel numbers to must be integers")
                return true
            }
            return false
        }).map({
            $0!
        })
        var cues : [Cue] = [
            X32SetDCANameCue(dca: dca, name: name, preWait: preWait),
            X32SetDCAColourCue(dca: dca, colour: X32Colour.BLUE, preWait: preWait)
        ]
        for channel in channels {
            cues.append(X32AssignChannelToDCACue(channel: channel, dca: dca, preWait: preWait))
            cues.append(X32SetChannelMixOnCue(channel: channel, on: true, preWait: preWait))
        }
        let enableDCACue : Cue = GroupCue(cueNumber: "", comment: "Enable DCA \(dca) - \(name)", page: nil, children: cues)
        return [enableDCACue]
    }
}