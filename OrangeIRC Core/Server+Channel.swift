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
    
    public func alreadyExists(room: String) -> Bool {
        for existingRoom in self.rooms {
            if room == existingRoom.name {
                return true
            }
        }
        return false
    }
    
    public func roomFrom(name: String) -> Room? {
        for room in self.rooms {
            if room.name == name {
                return room
            }
        }
        return nil
    }
    
}
