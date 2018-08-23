//
//  Mode.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/25/17.
//
//

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
