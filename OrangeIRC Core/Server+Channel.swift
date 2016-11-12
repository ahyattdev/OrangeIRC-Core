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
    
    public func findInAllRooms(user: String) -> User? {
        for room in rooms {
            let possibleUser = room.user(name: user)
            if possibleUser != nil {
                return possibleUser!
            }
        }
        
        return nil
    }
    
    public func findRoomsOf(user: User) -> [Room] {
        var rooms = [Room]()
        for room in rooms {
            for otherUser in room.users {
                if otherUser.name == user.name {
                    rooms.append(room)
                }
            }
        }
        return rooms
    }
    
    func getOrAddRoom(name: String, type: RoomType) -> Room {
        for room in rooms {
            if room.name == name && room.type == type{
                return room
            }
        }
        let room = Room(name: name, type: type, serverUUID: uuid)
        room.server = self
        rooms.append(room)
        return room
    }
    
}
