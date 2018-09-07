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

/// The mode of the IRC client
public struct ClientMode {
    
    /// Invisible mode
    internal(set) public var invisible = false
    /// Receives notices flag
    internal(set) public var receivesNotices = false
    /// Receives wallops flag
    internal(set) public var receivesWallops = false
    /// Operator mode
    internal(set) public var `operator` = false
    
    internal init(_ string: String) {
        update(with: string)
    }
    
    internal init() {
        self.init("")
    }
    
    internal mutating func update(with string: String) {
        if string.utf8.count < 2 {
            return
        }
        
        let value = string.utf8.first! == "+".utf8.first!
        
        for char in string.utf8.dropFirst() {
            switch String(char) {
            case "i":
                invisible = value
            case "s":
                receivesNotices = value
            case "w":
                receivesWallops = value
            case "o":
                `operator` = value
                
            default:
                break
            }
        }
    }
    
}
