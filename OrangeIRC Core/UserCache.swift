//
//  UserCache.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 11/11/16.
//
//

import Foundation

class UserCache {
    
    // The server associated with this cache
    weak var server: Server! {
        didSet {
            me.nick = server.nickname
            if !users.contains(me) {
                users.append(me)
            }
        }
    }
    
    // Represents our user
    var me = User("")
    
    // The cache of users
    var users = [User]()
    
    func goOffline() {
        for user in users {
            user.isOnline = false
        }
    }
    
    func getUser(by name: String) -> User? {
        for user in users {
            if user.nick == name {
                return user
            }
        }
        return nil
    }
    
    func channelsFor(user: User) -> [Room] {
        // FIXME: Should use WHOIS
        var channels = [Room]()
        
        for channelNode in user.channels {
            if let room = server.channelFrom(name: channelNode.name) {
                channels.append(room)
            }
        }
        
        return channels
    }
    
    func parse(userList: [String], for room: Channel) {
        for nicknameWithPrefix in userList {
            if nicknameWithPrefix.isEmpty {
                // Some servers put a space after the nickname list, causing our code to put in an empty nick
                continue
            }
            
            let splitUserData = split(nickname: nicknameWithPrefix)
            let user = getOrCreateUser(nickname: splitUserData.nickname)
            
            // If they are given in the list of users, they must be online
            
            user.isOnline = true
            
            if !room.contains(user: user) {
                room.users.append(user)
            }
            
            // Correct the metadata of the User
            updateMetadata(user: user, room: room, mode: splitUserData.mode)
            
            // If we have a private message room, we must mark it as not joined
            if let privateRoom = server.privateMessageFrom(user: user) {
                    user.isOnline = true
                let onlineEvent = UserOnlineLogEvent(sender: user, room: room)
                    privateRoom.log.append(onlineEvent)
                    server.delegate?.received(logEvent: onlineEvent, for: privateRoom)
            }
        }
    }
    
    func cacheContains(nickname: String) -> Bool {
        for user in users {
            if user.nick == nickname {
                return true
            }
        }
        return false
    }
    
    func handleQuit(user: User) {
        user.isOnline = false
        for channel in channelsFor(user: user) {
            let quitMessage = UserQuitLogEvent(sender: user, room: channel)
            channel.log.append(quitMessage)
            server.delegate?.received(logEvent: quitMessage, for: channel)
        }
        
        // If we have a private message room, we must mark it as not joined
        if let privateRoom = server.privateMessageFrom(user: user) {
            if privateRoom.otherUser.isOnline {
                privateRoom.otherUser.isOnline = false
                
                let offlineEvent = UserOfflineLogEvent(sender: user, room: privateRoom)
                privateRoom.log.append(offlineEvent)
                server.delegate?.received(logEvent: offlineEvent, for: privateRoom)
            }
        }
    }
    
    func getOrCreateUser(nickname: String) -> User {
        if nickname == server.nickname {
            return me
        }
        
        // See if we already have the user in the cache
        var user = getUser(by: nickname)
        
        // Create it if necessary
        if !cacheContains(nickname: nickname) {
            user = User(nickname)
            users.append(user!)
        }
        return user!
    }
    
    func updateMetadata(user: User, room: Channel, mode: User.Mode) {
        if !user.isOn(channel: room.name) {
            user.channels.append((room.name, mode, false))
        } else {
            user.set(mode: mode, for: room.name)
            user.set(away: false, for: room.name)
        }
    }
    
    func handleJoin(user: User, channel: Channel) {
        user.isOnline = true
        
        if me == user {
            channel.isJoined = true
            NotificationCenter.default.post(name: Notifications.RoomStateUpdated, object: channel)
            NotificationCenter.default.post(Notification(name: Notifications.RoomDataChanged))
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
        
        let logEvent = UserJoinLogEvent(sender: user, room: channel)
        channel.log.append(logEvent)
        server.delegate?.received(logEvent: logEvent, for: channel)
        
        if let privateRoom = server.privateMessageFrom(user: user) {
            if !privateRoom.otherUser.isOnline {
                let onlineEvent = UserOnlineLogEvent(sender: user, room: privateRoom)
                privateRoom.log.append(onlineEvent)
                server.delegate?.received(logEvent: onlineEvent, for: privateRoom)
            }
        }
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
    
    func handleLeave(user: User, channel: Channel) {
        if me == user {
            // We left
            channel.isJoined = false
            // Reset the users on this channel
            channel.users.removeAll()
            NotificationCenter.default.post(name: Notifications.RoomStateUpdated, object: channel)
            NotificationCenter.default.post(Notification(name: Notifications.RoomDataChanged))
        } else {
            // Remove the user object from the room
            for i in 0 ..< channel.users.count {
                if channel.users[i] === user {
                    channel.users.remove(at: i)
                    break
                }
            }
        }
        
        let logEvent = UserPartLogEvent(sender: user, room: channel)
        channel.log.append(logEvent)
        server.delegate?.received(logEvent: logEvent, for: channel)
        
        // Remove this room from the channels of the user
        user.removeFrom(channel: channel.name)
    }
    
}
