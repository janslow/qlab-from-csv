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
        var cues : [GroupCue] = csvFile.rows.map({
            (row : Dictionary<String, String>) -> GroupCue? in
            return self.convertRowToCue(row, subCueCategories: self._csvTemplate.categories, issues: issues);
            })
            .filter({ $0 != nil })
            .map({ $0! })
        // Sort the cues by cue number.
        return cues.map({
            $0 as Cue
        })
    }
    func convertRowToCue(row : Dictionary<String, String>, subCueCategories : Dictionary<String, ([String], Float) -> Cue>, issues : ParseIssueAcceptor) -> GroupCue? {
        // Each row must have a QLab value.
        let cueNumber = row[self._csvTemplate.IdColumn]
        if cueNumber == nil {
            log.error("Row Parser: Cue must have a QLab number")
            log.debug("\(row)")
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
                children += createSubCues(subCueString, cueCreator: cueCreator)
            }
        }
        // Construct and return the GroupCue
        return GroupCue(cueNumber: cueNumber!, comment: comment, page: page, children: children)
    }
    func createSubCues(cueString : String, cueCreator : CueParser) -> [Cue] {
        // Split the sub-cue string by commas.
        var cueStrings: [String] = cueString.componentsSeparatedByString(",")
        // For each sub-cue string...
        var cues : [Cue] = cueStrings.map({
                // ...Trim the whitespace...
                $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }).filter({
                // ...Ignore any empty strings...
                !$0.isEmpty
            }).map({
                (s : String) -> Cue in
                // ...Split the string into parts...
                var parts : [String] = s.componentsSeparatedByString("/")
                // ...Extract the pre-wait time...
                var preWait : Float = 0.0
                if parts.count > 1 {
                    let preWaitString = parts[parts.count - 1]
                    if preWaitString.hasPrefix("d") {
                        preWait = (preWaitString.substringFromIndex(advance(preWaitString.startIndex, 1)) as NSString).floatValue
                        parts = Array(parts[0...parts.count - 2])
                    }
                }
                // ...Create and return the cue.
                return cueCreator(parts: parts, preWait: preWait)
            })
        return cues
    }
}
