//
//  Mode.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/25/17.
//
//

import Foundation

public struct UserMode {
    
    public var invisible = false
    public var receivesNotices = false
    public var receivesWallops = false
    public var `operator` = false
    
    public init(_ string: String) {
        update(with: string)
    }
    
    public init() {
        self.init("")
    }
    
    public mutating func update(with string: String) {
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
