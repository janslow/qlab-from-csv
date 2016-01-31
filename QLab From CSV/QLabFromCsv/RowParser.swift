//
//  parser.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 20/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

class RowParser {
    private let _csvTemplate : CsvTemplate
    
    init(csvTemplate : CsvTemplate) {
        self._csvTemplate = csvTemplate
    }
    
    func load(csvFile : CsvFile, issues : ParseIssueAcceptor) -> [Cue] {
        // Create a GroupCue from each row.
        var cues : [Cue] = []
        for (i, row) in csvFile.rows.enumerate() {
            if let cue = convertRowToCue(row, subCueCategories: self._csvTemplate.ColumnToCueParserMap, issues: issues, line : i) {
                cues.append(cue)
            }
        }
        return cues
    }
    func convertRowToCue(row : Dictionary<String, String>, subCueCategories : Dictionary<String, CueParser>, issues : ParseIssueAcceptor, line : Int) -> GroupCue? {
        // Each row must have a QLab value.
        let cueNumber = row[self._csvTemplate.IdColumn]
        if cueNumber == nil {
            issues.add(IssueSeverity.ERROR, line: line, cause: nil, code: "MISSING_QLAB_NUMBER", details: "Cue must have a QLab number.")
            return nil
        }
        // Comment and Page values are optional.
        var comment : String?
        if let commentColumn = self._csvTemplate.CommentColumn {
            comment = row[commentColumn]
        } else {
            comment = nil
        }
        var page : String?
        if let pageColumn = self._csvTemplate.PageColumn {
            page = row[pageColumn]
        } else {
            page = nil
        }
        // Create all the child cues by creating cues for each category.
        var children : [Cue] = []
        for (columnName, cueCreator) in self._csvTemplate.ColumnToCueParserMap {
            // If there is a sub-cue value for the specified category, create the cues for that type.
            if let subCueString = row[columnName] {
                children += createSubCues(subCueString, cueCreator: cueCreator, issues: issues, line : line)
            }
        }
        // Construct and return the GroupCue
        return GroupCue(cueNumber: cueNumber!, comment: comment, page: page, children: children)
    }
    func createSubCues(cueString : String, cueCreator : CueParser, issues : ParseIssueAcceptor, line : Int) -> [Cue] {
        // Split the sub-cue string by commas.
        var cueStrings: [String] = cueString.componentsSeparatedByString(",")
        // For each sub-cue string...
        return cueStrings.map({
            // ...Trim the whitespace...
            $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }).filter({
            // ...Ignore any empty strings...
            !$0.isEmpty
        }).map({
            (s : String) -> [Cue] in
            // ...Split the string into parts...
            var parts : [String] = s.componentsSeparatedByString("/")
            // ...Extract the pre-wait time...
            var preWait : Float = 0.0
            if parts.count > 1 {
                let preWaitString = parts[parts.count - 1]
                if preWaitString.hasPrefix("d") {
                    preWait = (preWaitString.substringFromIndex(preWaitString.startIndex.advancedBy(1)) as NSString).floatValue
                    parts = Array(parts[0...parts.count - 2])
                }
            }
            // ...Create and return the cue.
            return cueCreator(parts: parts, preWait: preWait, issues: issues, line: line)
        }).reduce([] as [Cue], combine: {
            (aggregate : [Cue], next : [Cue]) in
            aggregate + next
        })
    }
}
