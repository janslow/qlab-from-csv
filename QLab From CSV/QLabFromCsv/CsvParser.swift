//
//  csv.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 20/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

public class CsvParser {
    public class func csv() -> CsvParser {
        return CsvParser(delimiter: ",")
    }
    
    private var delimiter : String
    
    init(delimiter : String) {
        self.delimiter = delimiter
    }
    
    func parse(contents : String) -> (headers: [String], rows: [Dictionary<String,String>])? {
        var lines: [String] = []
        contents.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()).enumerateLines { line, stop in lines.append(line) }
        
        if lines.count < 1 {
            println("ERROR: There must be at least one line including the header")
            return nil
        }
        
        let headers = lines[0].componentsSeparatedByString(",").map({
            (s : String) -> String in
            return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        })
        var rows : [Dictionary<String, String>] = []
        
        
        for (lineNumber, line) in enumerate(lines) {
            if lineNumber == 0 {
                continue
            }
            
            var row = Dictionary<String, String>()
            
            let scanner = NSScanner(string: line)
            let delimiter = ","
            let doubleQuote = NSCharacterSet(charactersInString: "\"")
            let whitespace = NSCharacterSet.whitespaceCharacterSet()
            
            for (index, header) in enumerate(headers) {
                scanner.scanCharactersFromSet(whitespace, intoString: nil)
                
                var value : NSString = ""
                if scanner.scanCharactersFromSet(doubleQuote, intoString: nil) {
                    var result : NSString?
                    while true {
                        scanner.scanUpToCharactersFromSet(doubleQuote, intoString: &result)
                        if result != nil {
                            value = value + result!
                        }
                        if scanner.scanString("\"\"", intoString: nil) {
                            value = value + "\""
                        } else {
                            scanner.scanCharactersFromSet(doubleQuote, intoString: nil)
                            break
                        }
                    }
                } else {
                    var result : NSString?
                    // Case where value is not quoted
                    scanner.scanUpToString(delimiter, intoString: &result)
                    if result != nil {
                        value = result!
                    }
                }
                // Trim whitespace
                var trimmedVal = value.stringByTrimmingCharactersInSet(whitespace)
                // If value is non-empty store it in the row
                if !trimmedVal.isEmpty {
                    row[header] = trimmedVal
                }
                // Remove whitespace and comma
                scanner.scanCharactersFromSet(whitespace, intoString: nil)
                scanner.scanString(delimiter, intoString: nil)
            }
            rows.append(row)
        }
        
        return (headers, rows)
    }
    func parseFromFile(path : String) -> (headers: [String], rows: [Dictionary<String,String>])? {
        if let contents = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) {
            return parse(contents)
        } else {
            println("ERROR: Unable to read CSV")
            return nil
        }
    }
}