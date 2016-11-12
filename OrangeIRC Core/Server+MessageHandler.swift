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
        
        switch message.command {
        case Command.Reply.WELCOME:
            self.isConnectingOrRegistering = false
            self.delegate?.didRegister(server: self)
            self.isRegistered = true
            for room in rooms {
                if room.joinOnConnect {
                    // Completes the feature of the Connect and Join button
                    join(channel: room.name)
                    room.joinOnConnect = false
                } else if room.autoJoin && !room.isJoined {
                    // Completes the room autojoin feature
                    join(channel: room.name)
                }
            }
            
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
            
        case Command.ERROR:
            guard let errorMessage = message.parameters else {
                print("Failed to get an ERROR message")
                delegate?.recieved(error: NSLocalizedString("UNKNOWN_ERROR", comment: "Unknown Error"), server: self)
                break
            }
            
            // Hide the ERROR some servers send when the client sends QUIT
            if errorMessage.contains("Quit: ") {
                break
            }
            
            delegate?.recieved(error: errorMessage, server: self)
            
        case Command.JOIN:
            guard let nick = message.prefix?.nickname else {
                break
            }
            
            var channelName = ""
            if message.target.count == 0 {
                if message.parameters != nil {
                    channelName = message.parameters!
                }
            } else {
                channelName = message.target[0]
            }
            
            if channelName.isEmpty {
                break
            }
            
            let room = getOrAddRoom(name: channelName, type: .Channel)
            
            if nick == self.nickname {
                // We joined a room
                room.isJoined = true
                self.delegate?.joined(room: room)
                for i in 0 ..< roomsFlaggedForAutoJoin.count {
                    let roomName = roomsFlaggedForAutoJoin[i]
                    if roomName == room.name {
                        room.autoJoin = true
                        roomsFlaggedForAutoJoin.remove(at: i)
                        break
                    }
                }
            }
            
            let logEvent = UserJoinLogEvent(sender: nick)
            room.log.append(logEvent)
            delegate?.recieved(logEvent: logEvent, for: room)
        
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
            guard let noticeMessage = message.parameters else {
                print("Failed to parse NOTICE")
                break
            }
            if message.target[0] == self.nickname {
                // This NOTICE is specifically sent to this nickname
                guard let sender = message.prefix?.nickname else {
                    print("Recieved a NOTICE without a prefix: \(message)")
                    break
                }
                self.delegate?.recieved(notice: noticeMessage, sender: sender, server: self)
            }
            
        case Command.PING:
            self.write(string: "\(Command.PONG) :\(message.parameters!)")
        
        case Command.Reply.YOURID:
            // Useless
            break
        
        case Command.Reply.STATSDLINE, Command.Reply.LUSERCLIENT, Command.Reply.LUSEROP, Command.Reply.LUSERUNKNOWN, Command.Reply.LUSERCHANNELS, Command.Reply.LUSERME, Command.Reply.ADMINME, Command.Reply.LOCALUSERS, Command.Reply.GLOBALUSERS:
            // These stats are not useful
            break
            
        case Command.Reply.MOTDSTART:
            // Not useful
            break
        case Command.Reply.MOTD:
            guard let parameters = message.parameters else {
                print("Recieved a MOTD message without the MOTD part")
                break
            }
            
            // This prevents a preceding newline at the start of the MOTD
            motd = motd.isEmpty ? parameters : "\(self.motd)\n\(parameters)"
            
        case Command.Reply.ENDOFMOTD:
            // Clean the MOTD of "- "
            motd = motd.replacingOccurrences(of: "\n- ", with: "\n")
            
            if motd.hasPrefix("- ") {
                motd = motd.replacingCharacters(in: motd.range(of: "- ")!, with: "")
            }
            
            if motd.hasPrefix(" \n") {
                motd = motd.replacingCharacters(in: motd.range(of: " \n")!, with: "")
            }
            
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
            guard let nick = message.prefix?.nickname else {
                print("The server sent a QUIT message without specifying who quit")
                break
            }
            // See if it is for us
            if nick == self.nickname {
                reset()
            }
            
            // Log it
            guard let user = findInAllRooms(user: nick) else {
                print("Could not find the User for which to log the quit message for")
                break
            }
            
            let logEvent = UserQuitLogEvent(sender: nick)
            
            for room in findRoomsOf(user: user) {
                room.log.append(logEvent)
                delegate?.recieved(logEvent: logEvent, for: room)
            }
            
        default:
            print(message.message)
            print("Unimplemented command handle: \(message.command)")
        }
        
        socket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
    }
    
}
