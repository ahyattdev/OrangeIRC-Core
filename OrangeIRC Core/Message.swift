// This file of part of the Swift IRC client framework OrangeIRC Core.
//
// Copyright © 2016 Andrew Hyatt
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

let SPACE = " "
let SLASH = "/"
let COLON = ":"
let EXCLAMATION_MARK = "!"
let AT_SYMBOL = "@"
let CARRIAGE_RETURN = "\r\n"
let EMPTY = ""

internal class Message {
    
    internal typealias Tag = (key: String, value: String?, vendor: String?)
    
    internal struct Prefix {
        
        internal var prefix: String
        internal var servername: String?
        internal var nickname: String?
        internal var user: String?
        internal var host: String?
        
        internal init?(_ string: String) {
            self.prefix = string
            
            if string.contains(EXCLAMATION_MARK) && string.contains(AT_SYMBOL) {
                // One of the msgto formats
                let exclamationMark = string.range(of: EXCLAMATION_MARK)!
                let atSymbol = string.range(of: AT_SYMBOL)!
                self.nickname = String(string[string.startIndex ..< exclamationMark.lowerBound])
                self.user = String(string[exclamationMark.upperBound ..< atSymbol.lowerBound])
                self.host = String(string[atSymbol.upperBound ..< string.endIndex])
            } else {
                self.servername = prefix
            }
        }
        
        internal func toString() -> String {
            if let nickname = self.nickname, let user = self.user, let host = self.host {
                return nickname + EXCLAMATION_MARK + user + AT_SYMBOL + host
            } else {
                guard let servername = self.servername else {
                    return "PREFIX UNKNOWN"
                }
                return servername
            }
        }
        
    }
    
    internal var message: String
    internal var prefix: Prefix?
    internal var command: String
    internal var target: [String]
    internal var parameters: String?
    
    internal var tags = [Tag]()
    
    internal init?(_ string: String) {
        
        var trimmedString = string.replacingOccurrences(of: CARRIAGE_RETURN, with: EMPTY)
        
        self.message = trimmedString
        
        guard let firstSpaceIndex = trimmedString.range(of: " ")?.lowerBound else {
            // The message is invalid if there isn't a single space
            return nil
        }
        
        var possibleTags = trimmedString[trimmedString.startIndex ..< firstSpaceIndex]
        
        if !possibleTags.isEmpty && possibleTags.hasPrefix("@") {
            // There are tags present
            // Remove the @ symbol
            possibleTags.remove(at: possibleTags.startIndex)
            
            // Seperate by ;
            for tag in possibleTags.components(separatedBy: ";") {
                /*
                 <tag>           ::= <key> ['=' <escaped value>]
                 <key>           ::= [ <vendor> '/' ] <sequence of letters, digits, hyphens (`-`)>
                 */
                guard let equalSignIndex = tag.range(of: "=")?.lowerBound else {
                    print("Invalid tag: \(tag)")
                    continue
                }
                
                var key = tag[tag.startIndex ..< equalSignIndex]
                var vendor: String?
                if key.contains("/") {
                    // A vendor is present
                    let slash = key.range(of: "/")!.lowerBound
                    vendor = String(key[key.startIndex ..< slash])
                    key = key[key.index(after: slash) ..< key.endIndex]
                }
                
                var value: String? = String(tag[tag.index(after: equalSignIndex) ..< tag.endIndex])
                
                if value!.isEmpty {
                    value = nil
                }
                
                guard !key.isEmpty else {
                    print("Unexpected empty key: \(tag)")
                    continue
                }
                
                tags.append((key: String(key), value: value, vendor: vendor))
            }
            
            // Remove the tags so the old code works
            trimmedString.removeSubrange(trimmedString.startIndex ... firstSpaceIndex)
        }
        
        if trimmedString[trimmedString.startIndex] == Character(COLON) {
            // There is a prefix, and we must handle and trim it
            let indexAfterColon = trimmedString.index(after: trimmedString.startIndex)
            let indexOfSpace = trimmedString.range(of: SPACE)!.lowerBound
            let prefixString = trimmedString[indexAfterColon ..< indexOfSpace]
            guard let prefix = Prefix(String(prefixString)) else {
                // Present but invalid prefix.
                // The whole message may be corrupt, so let's give up 🤡.
                return nil
            }
            self.prefix = prefix
            // Trim off the prefix
            trimmedString = String(trimmedString[trimmedString.index(after: indexOfSpace) ..< trimmedString.endIndex])
        }
        
        if let colonSpaceRange = trimmedString.range(of: " :") {
            // There are parameters
            let commandAndTargetString = trimmedString[trimmedString.startIndex ..< colonSpaceRange.lowerBound]
            // Space seperated array
            var commandAndTargetComponents = commandAndTargetString.components(separatedBy: " ")
            self.command = commandAndTargetComponents.remove(at: 0)
            self.target = commandAndTargetComponents
            
            // If the command is a 3-didgit numeric, the first target must go
            if let cmd = Int(command) {
                if cmd >= 0 && cmd < 1000  && target.count > 0 {
                    target.remove(at: 0)
                }
            }
            
            // If this check if not performed, this code could crash if the last character of trimmedString is a colon
            if colonSpaceRange.upperBound != trimmedString.endIndex {
                var parametersStart = trimmedString.index(after: colonSpaceRange.upperBound)
                // Fixes a bug where the first character of the parameters is cut off
                parametersStart = trimmedString.index(before: parametersStart)
                self.parameters = String(trimmedString[parametersStart ..< trimmedString.endIndex])
            }
        } else {
            // There are no parameters
            var spaceSeperatedArray = trimmedString.components(separatedBy: " ")
            self.command = spaceSeperatedArray.remove(at: 0)
            self.target = spaceSeperatedArray
        }
    }
    
}
