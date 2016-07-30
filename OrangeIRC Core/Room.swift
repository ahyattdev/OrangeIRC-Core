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
    
    public var hasTopic = true
    
    public var isJoined = false
    
    public var type: RoomType
    
    public init(name: String, type: RoomType, server: Server) {
        self.name = name
        self.type = type
        self.server = server
    }
    
}
