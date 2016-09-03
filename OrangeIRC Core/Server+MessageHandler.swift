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
