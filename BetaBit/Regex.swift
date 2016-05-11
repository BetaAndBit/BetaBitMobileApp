//
//  Regex.swift
//  BetaBit
//
//  Created by Piotr Dudek on 16/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation

class Regex {
    
    static func listGroups(pattern: String, inString string: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern, options: [.CaseInsensitive])
        
        let range = NSMakeRange(0, string.characters.count)
        let matches = regex.matchesInString(string, options: [], range: range)
        
        var groupMatches = [String]()
        for match in matches {
            let rangeCount = match.numberOfRanges
            
            for group in 0..<rangeCount {
                groupMatches.append((string as NSString).substringWithRange(match.rangeAtIndex(group)))
            }
        }
        
        return groupMatches
    }
}
