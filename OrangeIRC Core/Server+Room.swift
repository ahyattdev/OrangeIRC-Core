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
    
    func getOrAddRoom(name: String, type: RoomType) -> Room {
        for room in rooms {
            if room.name == name && room.type == type {
                return room
            }
        }
        let room = Room(name: name, type: type, serverUUID: uuid)
        room.server = self
        rooms.append(room)
        return room
    }
    
    @discardableResult
    public func startPrivateMessageSession(_ otherNick: String) -> Room {
        // Should handle everything from creating the room to telling the delegate about it
        // We started a new private message session
        let user = userCache.getOrCreateUser(nickname: otherNick)
        
        let room = Room(name: otherNick, type: .PrivateMessage, serverUUID: uuid)
        room.server = self
        room.otherUser = user
        rooms.append(room)
        
        room.isJoined = true
        
        // We won't create a join room log event, those aren't really a thing with private messages
        delegate?.joined(room: room)
        
        return room
    }
    
}
