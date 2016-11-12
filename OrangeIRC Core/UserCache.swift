//
//  UserCache.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 11/11/16.
//
//

import Foundation

class UserCache {
    
    var _server: Server?
    
    // The server associated with this cache
    var server: Server {
        get {
            return _server!
        }
    }
    
    // Represents our user
    var me: User
    
    // The cache of users
    var users = [User]()
    
    init() {
        me = User(name: "")
    }
    
    func set(server: Server) {
        _server = server
        me.isSelf = true
        me.name = server.nickname
        users.append(me)
    }
    
    func getUser(by name: String) -> User? {
        for user in users {
            if user.name == name {
                return user
            }
        }
        return nil
    }
    
    func channelsFor(user: User) -> [Room] {
        var channels = [Room]()
        
        for channelNode in user.channels {
            if let room = server.roomFrom(name: channelNode.name) {
                channels.append(room)
            }
        }
        
        return channels
    }
    
    func parse(userList: [String], for room: Room) {
        for nicknameWithPrefix in userList {
            let splitUserData = split(nickname: nicknameWithPrefix)
            let user = getOrCreateUser(nickname: splitUserData.nickname)
            
            if !room.contains(user: user) {
                room.users.append(user)
            }
            
            // Correct the metadata of the User
            updateMetadata(user: user, room: room, mode: splitUserData.mode)
        }
    }
    
    func cacheContains(nickname: String) -> Bool {
        for user in users {
            if user.name == nickname {
                return true
            }
        }
        return false
    }
    
    func handleQuit(user: User) {
        let quitMessage = UserQuitLogEvent(sender: user.name)
        for channel in channelsFor(user: user) {
            channel.log.append(quitMessage)
            server.delegate?.recieved(logEvent: quitMessage, for: channel)
        }
    }
    
    func getOrCreateUser(nickname: String) -> User {
        // See if we already have the user in the cache
        var user = getUser(by: nickname)
        
        // Create it if necessary
        if !cacheContains(nickname: nickname) {
            user = User(name: nickname)
            users.append(user!)
        }
        return user!
    }
    
    func updateMetadata(user: User, room: Room, mode: User.Mode) {
        if !user.isOn(channel: room.name) {
            user.channels.append((room.name, mode, false))
        } else {
            user.set(mode: mode, for: room.name)
            user.set(away: false, for: room.name)
        }
    }
    
    func handleJoin(user: User, channel: Room) {
        if user.isSelf {
            channel.isJoined = true
            server.delegate?.joined(room: channel)
            // Do autojoin
            for i in 0 ..< server.roomsFlaggedForAutoJoin.count {
                let roomName = server.roomsFlaggedForAutoJoin[i]
                if roomName == channel.name {
                    server.roomsFlaggedForAutoJoin.remove(at: i)
                    break
                }
            }
        }
        
        updateMetadata(user: user, room: channel, mode: .None)
        
        let logEvent = UserJoinLogEvent(sender: user.name)
        channel.log.append(logEvent)
        
        server.delegate?.recieved(logEvent: logEvent, for: channel)
    }
    
    func split(nickname: String) -> (nickname: String, mode: User.Mode) {
        var cleanNick = nickname
        let prefix = nickname.substring(to: nickname.index(after: nickname.startIndex))
        let uchar = unichar(prefix.utf16[prefix.utf16.startIndex])
        if User.Mode.PREFIX_CHARACTER_SET.characterIsMember(uchar) {
            cleanNick.remove(at: cleanNick.startIndex)
        }
        
        var mode: User.Mode = .None
        
        if let derivedMode = User.Mode(rawValue: prefix) {
            mode = derivedMode
        }
        
        return (cleanNick, mode)
    }
    
    func handleLeave(user: User, channel: Room) {
        if user.isSelf {
            // We left
            channel.isJoined = false
            server.delegate?.left(room: channel)
        }
        
        let logEvent = UserPartLogEvent(sender: user.name)
        channel.log.append(logEvent)
        server.delegate?.recieved(logEvent: logEvent, for: channel)
        
        // Remove this room from the channels of the user
        user.removeFrom(channel: channel.name)
    }
    
}