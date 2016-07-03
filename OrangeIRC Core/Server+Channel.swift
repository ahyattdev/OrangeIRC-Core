//
//  Server+Channel.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

public extension Server {
    
    public func join(channel: String) {
        self.write(string: "\(Command.JOIN) \(channel)")
    }
    
    public func leave(channel: String) {
        self.write(string: "\(Command.PART) \(channel)")
    }
}
