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
        // Append "#" if no other prefixes are detected
        if let first = channel.utf16.first {
            if !Channel.CHANNEL_PREFIXES.characterIsMember(first) {
                write(string: "\(Command.JOIN) #\(channel)")
            }
        }

        write(string: "\(Command.JOIN) \(channel)")
    }
    
    public func leave(channel: String) {
        write(string: "\(Command.PART) \(channel)")
    }
    
    public func alreadyExists(_ channelName: String) -> Bool {
        for existingRoom in self.rooms {
            if let channel = existingRoom as? Channel {
                if channel.name == channelName {
                    return true
                }
            }
        }
        return false
    }
    
    public func channelFrom(name: String) -> Channel? {
        for room in self.rooms {
            if let channel = room as? Channel {
                if channel.name == name {
                    return channel
                }
            }
        }
        return nil
    }
    
    public func privateMessageFrom(user: User) -> PrivateMessage? {
        for room in rooms {
            if let privateMessageRoom = room as? PrivateMessage {
                if privateMessageRoom.otherUser == user {
                    return privateMessageRoom
                }
            }
        }
        return nil
    }
    
    func getOrAddChannel(_ name: String) -> Channel {
        for room in rooms {
            if let channel = room as? Channel {
                if channel.name == name {
                    return channel
                }
            }
        }
        let channel = Channel(name)
        channel.server = self
        rooms.append(channel)
        return channel
    }
    
    public func startPrivateMessageSession(_ otherNick: String, with message: String) {
        startPrivateMessageSession(otherNick)
        write(string: "\(Command.PRIVMSG) \(otherNick) :\(message)")
    }
    
    @discardableResult
    public func startPrivateMessageSession(_ otherNick: String) -> Room {
        // Should handle everything from creating the room to telling the delegate about it
        // We started a new private message session
        let user = userCache.getOrCreateUser(nickname: otherNick)
        
        let room = PrivateMessage(user)
        room.server = self
        rooms.append(room)
        
        // We won't create a join room log event, those aren't really a thing with private messages
        NotificationCenter.default.post(name: Notifications.RoomCreated, object: room)
        
        return room
    }
    
    public func delete(room: Room) {
        
        // Leave gracefully
        if let channel = room as? Channel {
            if channel.isJoined {
                leave(channel: channel.name)
            }
        }
        
        // Remove from the array of rooms of the server of this room
        for i in 0 ..< rooms.count {
            if rooms[i] == room {
                rooms.remove(at: i)
                break
            }
        }
        
        ServerManager.shared.saveData()
        
        NotificationCenter.default.post(name: Notifications.ServerDataChanged, object: nil)
    }
    
}
