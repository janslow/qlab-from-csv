//
//  csv.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 20/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Foundation

public class Csv {
    public class func parse(contents : String) -> (headers: [String], rows: [Dictionary<String,String?>]) {
        var lines: [String] = []
        contents.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()).enumerateLines { line, stop in lines.append(line) }
        
        if lines.count < 1 {
            println("There must be at least one line including the header")
            exit(EXIT_FAILURE)
        }
        
        let headers = lines[0].componentsSeparatedByString(",").map({
            (s : String) -> String in
            return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        })
        var rows : [Dictionary<String, String?>] = []
        
        
        for (lineNumber, line) in enumerate(lines) {
            if lineNumber == 0 {
                continue
            }
            
            var row = Dictionary<String, String?>()
            
            let scanner = NSScanner(string: line)
            let delimiter = ","
            let doubleQuote = NSCharacterSet(charactersInString: "\"")
            let whitespace = NSCharacterSet.whitespaceCharacterSet()
            
            for (index, header) in enumerate(headers) {
                scanner.scanCharactersFromSet(whitespace, intoString: nil)
                
                var value : NSString? = nil
                if scanner.scanCharactersFromSet(doubleQuote, intoString: nil) {
                    value = ""
                    var result : NSString? = nil
                    while true {
                        scanner.scanUpToCharactersFromSet(doubleQuote, intoString: &result)
                        if result != nil {
                            value = value! + result!
                        }
                        if scanner.scanString("\"\"", intoString: nil) {
                            value = value! + "\""
                        } else {
                            scanner.scanCharactersFromSet(doubleQuote, intoString: nil)
                            break
                        }
                    }
                } else {
                    // Case where value is not quoted
                    scanner.scanUpToString(delimiter, intoString: &value)
                }
                // Trim whitespace
                var trimmedVal = value?.stringByTrimmingCharactersInSet(whitespace)
                // If value is empty, set it to nil
                if trimmedVal != nil && trimmedVal!.isEmpty {
                    trimmedVal = nil
                }
                row[header] = trimmedVal
                // Remove whitespace and comma
                scanner.scanCharactersFromSet(whitespace, intoString: nil)
                scanner.scanString(delimiter, intoString: nil)
            }
            rows.append(row)
        }
        
        return (headers, rows)
    }
    public class func parseFromFile(path : String) -> (headers: [String], rows: [Dictionary<String,String?>]) {
        let contents = String(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding, error: nil)
        if contents == nil {
            println("Unable to read CSV")
            exit(EXIT_FAILURE)
        }
        return parse(contents!)
    }
}