//
//  X32CsvParser.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-25.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public class X32CsvParser {
    private let CHARACTER_COLUMN = "Character"
    private let CHANNEL_COLUMN = "Channel"
    
    private let CHANNELS_TABLE_INDICATOR = "#Channels"
    private let CUES_TABLE_INDICATOR = "#Cues"
    
    func parse(contents : String, issues : ParseIssueAcceptor) -> CsvFile? {
        if !contents.hasPrefix(CHANNELS_TABLE_INDICATOR) {
            return CsvParser.csv().parse(contents, issues: issues)
        }
        
        var lines: [String] = []
        contents.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()).enumerateLines { line, stop in lines.append(line) }
        lines = Array(lines[1...(lines.count - 1)])
        
        var channelMappingLines : [String]?
        var cueLines : [String]?
        for i in 0...(lines.count - 1) {
            if lines[i].hasPrefix(CUES_TABLE_INDICATOR) {
                channelMappingLines = Array(lines[0...(i - 1)])
                cueLines = Array(lines[(i + 1)...(lines.count - 1)])
                break
            }
        }
        
        if channelMappingLines == nil {
            issues.add(IssueSeverity.FATAL, line: nil, cause: nil, code: "MISSING_DIVIDER", details: "Missing \(CUES_TABLE_INDICATOR) divider between channel mappings and cues.")
            return nil
        }
        
        let channelMappingsNillable = parseChannelMappings(channelMappingLines!, issues: issues)
        let cuesNillable = CsvParser.csv().parse(cueLines!, issues: issues)
        
        if let channelMappings = channelMappingsNillable, cues = cuesNillable {
            return transformCuesCsv(cues, channelMappings: channelMappings, issues: issues)
        } else {
            if !issues.HasFatalErrors {
                issues.add(IssueSeverity.FATAL, line: nil, cause: nil, code: "UNKNOWN_ERROR", details: "Unknown error when combined CSV.")
            }
            return nil
        }
    }
    
    func parseChannelMappings(lines : [String], issues : ParseIssueAcceptor) -> Dictionary<String, Int>? {
        let csvParser = CsvParser.csv()
        
        if let csv = csvParser.parse(lines, issues: issues) {
            var channelMappings = Dictionary<String, Int>()
            for row in csv.rows {
                if let character = row[CHARACTER_COLUMN], channelString = row[CHANNEL_COLUMN], channel = channelString.toInt() {
                    channelMappings[character] = channel
                } else {
                    issues.add(IssueSeverity.ERROR, line: nil, cause: "\(row)", code: "INVALID_CHANNEL_MAPPING", details: "Unable to parse channel mapping")
                }
            }
            return channelMappings
        } else {
            if !issues.HasFatalErrors {
                issues.add(IssueSeverity.FATAL, line: nil, cause: nil, code: "UNKNOWN_ERROR", details: "Unknown error when parsing Channel Mappings CSV.")
            }
            return nil
        }
    }
    
    func parseFromFile(path : String, issues : ParseIssueAcceptor) -> CsvFile? {
        if let contents = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) {
            return parse(contents, issues: issues)
        } else {
            issues.add(IssueSeverity.FATAL, line: nil, cause: nil, code: "IO_ERROR", details: "Unable to read file")
            return nil
        }
    }
    
    func transformCuesCsv(cues : CsvFile, channelMappings : Dictionary<String, Int>, issues : ParseIssueAcceptor) -> CsvFile? {
        var success = true
        let allChannels = Set(channelMappings.values)
        var rows = cues.rows.map({
            (oldRow : Dictionary<String, String>) -> Dictionary<String, String> in
            var row = oldRow
            var unassignedChannels = allChannels
            for column in cues.headers {
                if column.hasPrefix("DCA") || column.hasPrefix("VCA") {
                    if let cell = row[column] {
                        let characters : [String] = cell.componentsSeparatedByString(",").map({
                            $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        })
                        if characters.isEmpty {
                            row[column] = "*"
                        } else {
                            let channels = characters.map({
                                (character : String) -> Int? in
                                if let channel = channelMappings[character] {
                                    if unassignedChannels.remove(channel) == nil {
                                        issues.add(IssueSeverity.WARN, line: nil, cause: character, code: "REASSIGNED_CHARACTER", details: "Character has already been assigned.")
                                    }
                                    return channel
                                } else {
                                    issues.add(IssueSeverity.ERROR, line: nil, cause: character, code: "UNKNOWN_CHARACTER", details: "Character doesn't have an associated channel number.")
                                    return nil
                                }
                            }).filter({ $0 != nil }).map({ $0! })
                            let name = "+".join(characters)
                            let channelsString = "+".join(channels.map({ String($0) }))
                            
                            row[column] = "\(name)/\(channelsString)"
                        }
                    } else {
                        row[column] = "*"
                    }
                }
            }
            row[X32CsvTemplateFactory.MUTE_COLUMN] = ",".join(Array(unassignedChannels).map({ String($0) }))
            return row
        })
        
        if success {
            return (headers: cues.headers + [X32CsvTemplateFactory.MUTE_COLUMN], rows: rows)
        } else {
            return nil
        }
    }
}