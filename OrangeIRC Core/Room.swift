//
//  Room.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

public class Room {
    
    public var server: Server
    
    public var log = [LogEvent]()
    
    public var otherUsers = [User]()
    
    public var name: String
    
    public var topic: String?
    
    public var isJoined = false
    
    // Type not decided yet
    public var mode = "Placeholder"
    
    public init(name: String, server: Server) {
        self.name = name
        self.server = server
    }
    
}
