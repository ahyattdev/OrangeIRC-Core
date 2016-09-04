//
//  Server+MessageHandler.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/2/16.
//
//

import Foundation
import CocoaAsyncSocket

extension Server {
    
    func handle(message: Message) {
        print(message.message)
        switch message.command {
        case Command.Reply.WELCOME:
            self.isConnectingOrRegistering = false
            self.delegate?.didRegister(server: self)
            self.isRegistered = true
            
        case Command.Reply.YOURHOST:
            // Not useful
            break
            
        case Command.Reply.CREATED:
            // Not useful
            break
            
        case Command.Reply.MYINFO:
            // Not useful
            break
            
        case Command.Reply.BOUNCE:
            // According to RFC 2812, this is a bounce message
            // But Freenode sends various server variables
            break
        case Command.JOIN:
            guard let nick = message.prefix?.nickname else {
                break
            }
            
            let channelName = message.target[0]
            var room: Room?
            if !alreadyExists(room: channelName) {
                // Create a new room with log
                room = Room(name: channelName, type: .Channel, server: self)
                self.rooms.append(room!)
            } else {
                room = roomFrom(name: channelName)
            }
            
            if nick == self.nickname {
                // We joined a room
                room!.isJoined = true
                self.delegate?.joined(room: room!)
            }
            
            let logEvent = UserJoinLogEvent(sender: nick)
            room!.log.append(logEvent)
            delegate?.recieved(logEvent: logEvent, for: room!)
        
        case Command.PART:
            guard let nick = message.prefix?.nickname else {
                break
            }
            
            let roomName = message.target[0]
            
            guard let room = roomFrom(name: roomName) else {
                break
            }
            
            if nick == self.nickname {
                // We left
                room.isJoined = false
                delegate?.left(room: room)
            }
            
            let logEvent = UserPartLogEvent(sender: nick)
            room.log.append(logEvent)
            delegate?.recieved(logEvent: logEvent, for: room)
            
        case Command.NOTICE:
            if message.target[0] == self.nickname {
                // This NOTICE is specifically sent to this nickname
                self.delegate?.recieved(notice: message.parameters!, sender: message.prefix!.nickname!, server: self)
            }
            
        case Command.PING:
            self.write(string: "\(Command.PONG) :\(message.parameters!)")
            
        case Command.Reply.MOTDSTART:
            // Not useful
            break
        case Command.Reply.MOTD:
            self.motd = "\(self.motd)\n\(message.parameters!)"
            
        case Command.Reply.ENDOFMOTD:
            self.finishedReadingMOTD = true
            self.delegate?.finishedReadingMOTD(server: self)
            
        case Command.Reply.NOTOPIC:
            let channelName = message.target[0]
            guard let channel = roomFrom(name: channelName) else {
                break
            }
            channel.hasTopic = false
            
        case Command.Reply.TOPIC:
            let channelName = message.target[1]
            guard let channel = roomFrom(name: channelName) else {
                break
            }
            channel.topic = message.parameters
            channel.hasTopic = true
        
        case Command.PRIVMSG:
            guard message.target.count > 0 else {
                print("Could not get the room for a PRIVMSG")
                break
            }
            
            guard let contents = message.parameters else {
                print("Got a PRIVMSG without a message")
                break
            }
            
            let roomName = message.target[0]
            
            guard let room = roomFrom(name: roomName) else {
                print("Recieved a PRIVMSG for an unknown room")
                break
            }
            
            guard let senderNick = message.prefix?.nickname else {
                break
            }
            
            guard let sender = room.user(name: senderNick) else {
                print("Could not identify the sender of a PRIVMSG")
                break
            }
            
            let logEvent = MessageLogEvent(contents: contents, sender: sender)
            room.log.append(logEvent)
            delegate?.recieved(logEvent: logEvent, for: room)
        
        case Command.Reply.NAMREPLY:
            if message.target.count != 3 {
                print("Error parsing NAMREPLY")
                break
            }
            
            let channelName = message.target[2]
            
            guard let room = roomFrom(name: channelName) else {
                print("Got a list of users in a room, but did not have data on the room!")
                break
            }
            
            guard let nicknames = message.parameters?.components(separatedBy: " ") else {
                print("Did not recieve a list of users during NAMREPLY")
                break
            }
            
            for nick in nicknames {
                room.addUser(nick: nick)
            }
            
        case Command.Reply.ENDOFNAMES:
            if message.target.count < 1 {
                break
            }
            
            let roomName = message.target[1]
            guard let room = roomFrom(name: roomName) else {
                break
            }
            
            room.hasCompleteUsersList = true
            delegate?.finishedReadingUserList(room: room)
            
        case Command.QUIT:
            reset()
            // No point reading any more data
            return
        default:
            print(message.message)
            print("Unimplemented command handle: \(message.command)")
        }
        
        socket?.readData(to: AsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
    }
    
}
