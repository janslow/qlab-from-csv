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
        let cueNumber = row[self._csvTemplate.idCategory]
        if cueNumber == nil {
            log.error("Row Parser: Cue must have a QLab number")
            log.debug("\(row)")
            return nil
        }
        // Comment and Page values are optional.
        var comment : String?
        if let commentCategory = self._csvTemplate.commentCategory {
            comment = row[commentCategory]
        } else {
            comment = nil
        }
        var page : String?
        if let pageCategory = self._csvTemplate.pageCategory {
            page = row[pageCategory]
        } else {
            page = nil
        }
        // Create all the child cues by creating cues for each category.
        var children : [Cue] = []
        for (categoryName, categoryCueCreator) in subCueCategories {
            // If there is a sub-cue value for the specified category, create the cues for that type.
            if let subCueString = row[categoryName] {
                children += createSubCues(subCueString, cueCreator: categoryCueCreator)
            }
        }
        // Construct and return the GroupCue
        return GroupCue(cueNumber: cueNumber!, comment: comment, page: page, children: children)
    }
    func createSubCues(cueString : String, cueCreator : ([String], Float) -> Cue) -> [Cue] {
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
                return cueCreator(parts, preWait)
            })
        return cues
    }
}