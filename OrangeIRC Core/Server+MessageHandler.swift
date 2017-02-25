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
            self.delegate?.registeredSuccessfully(self)
            self.isRegistered = true
            for room in rooms {
                if room.joinOnConnect {
                    // Completes the feature of the Connect and Join button
                    join(channel: room.name)
                    room.joinOnConnect = false
                } else if room.autoJoin && !room.isJoined && room.type == .Channel {
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
                delegate?.recieved(error: NSLocalizedString("UNKNOWN_ERROR", comment: "Unknown Error"), on: self)
                break
            }
            
            // Hide the ERROR some servers send when the client sends QUIT
            if errorMessage.contains("Quit: ") {
                break
            }
            
            delegate?.recieved(error: errorMessage, on: self)
            
        case Command.JOIN:
            guard let nick = message.prefix?.nickname else {
                print("The message for JOIN had no prefix and/or nickname")
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
                print("Invalid channel name")
                break
            }
            
            let room = getOrAddRoom(name: channelName, type: .Channel)
            
            // Set the autojoin setting if necessary
            for i in 0 ..< roomsFlaggedForAutoJoin.count {
                let roomName = roomsFlaggedForAutoJoin[i]
                if roomName == room.name {
                    room.autoJoin = true
                    roomsFlaggedForAutoJoin.remove(at: i)
                    break
                }
            }
            
            let user = userCache.getOrCreateUser(nickname: nick)
            
            if room.type == .Channel {
                room.sortUsers()
            }
            
            userCache.handleJoin(user: user, channel: room)
        
        case Command.PART:
            guard let nick = message.prefix?.nickname else {
                print("Recieved a PART message without a prefix")
                break
            }
            
            let roomName = message.target[0]
            
            guard let room = roomFrom(name: roomName) else {
                print("Could not get room for room name")
                break
            }
            
            guard let user = userCache.getUser(by: nick) else {
                print("Could not get user for nickname")
                break
            }
            
            userCache.handleLeave(user: user, channel: room)
            
        case Command.NOTICE:
            guard let noticeMessage = message.parameters else {
                print("Failed to parse NOTICE")
                break
            }
            if message.target[0] == self.nickname {
                if let servername = message.prefix?.servername, let message = message.parameters {
                    // Notice from the server, not a user
                    delegate?.recieved(notice: message, sender: servername, on: self)
                    break
                }
                
                guard let sender = message.prefix?.nickname else {
                    print("Recieved a NOTICE without a prefix: \(message)")
                    break
                }
                
                if sender == "NickServ" {
                    // We take care of these
                    handleNickServ(noticeMessage)
                } else {
                    self.delegate?.recieved(notice: noticeMessage, sender: sender, on: self)
                }
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
            motd = motd == nil ? parameters : "\(self.motd!)\n\(parameters)"
            
        case Command.Reply.ENDOFMOTD:
            // Clean the MOTD of "- "
            if var motd = motd {
                motd = motd.replacingOccurrences(of: "\n- ", with: "\n")
                
                if motd.hasPrefix("- ") {
                    motd = motd.replacingCharacters(in: motd.range(of: "- ")!, with: "")
                }
                
                if motd.hasPrefix(" \n") {
                    motd = motd.replacingCharacters(in: motd.range(of: " \n")!, with: "")
                }
                
                self.motd = motd
                
                self.delegate?.motdUpdated(self)
            }
            
        case Command.Reply.NOTOPIC:
            let channelName = message.target[0]
            guard let channel = roomFrom(name: channelName) else {
                break
            }
            channel.hasTopic = false
            
        case Command.Reply.TOPIC:
            let channelName = message.target[0]
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
            
            var roomName = message.target[0]
            
            guard roomName.characters.count > 1 else {
                break
            }
            
            guard var param = message.parameters else {
                break
            }
            
            
            let isPrivate = !Room.CHANNEL_PREFIXES.characterIsMember(roomName.utf16.first!)
            
            if isPrivate {
                // The IRC protocol puts our nickname as the roomname
                roomName = message.prefix!.nickname!
            }
            
            let isCommand = param.characters.first == "\u{01}" && param.characters.last == "\u{01}"
            
            if isPrivate && isCommand {
                // This is a command
                // Get rid of the first and last characters
                
                param = param[param.index(after: param.startIndex) ..< param.index(before: param.endIndex)]
                
                var response: String?
                var shouldReply = true
                
                switch param {
                    
                case Command.TIME:
                    let df = DateFormatter()

                    df.locale = Locale(identifier: "en_US_POSIX")
                    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    response = df.string(from: Date())
                
                case Command.PING:
                    // No arguments here, just PING as a response
                    break
                    
                case Command.VERSION:
                    let info = Bundle.main.infoDictionary
                    guard let version = info?["CFBundleShortVersionString"], let build = info?["CFBundleVersion"] else {
                        print("Failed to get version number")
                        shouldReply = false
                        break
                    }
                    response = "OrangeIRC \(version) (\(build))"
                
                default:
                    print("Unknown private message command: \(param)")
                    shouldReply = false
                }
                
                if let response = response, shouldReply {
                    write(string: "\(Command.NOTICE) \(message.prefix!.nickname!) :\u{01}\(param) \(response)\u{01}")
                } else if shouldReply {
                    write(string: "\(Command.NOTICE) \(message.prefix!.nickname!) :\u{01}\(param)\u{01}")
                }
                
            } else {
                
                var room = roomFrom(name: roomName)
                
                if room == nil && !isPrivate {
                    print("Recieved a PRIVMSG for an unknown channel")
                    break
                }
                
                if room == nil && isPrivate {
                    room = startPrivateMessageSession(message.prefix!.nickname!)
                } else if room != nil && isPrivate {
                    room!.otherUser!.isOnline = true
                }
                
                var sender: User?
                
                if room!.type == .PrivateMessage {
                    sender = room!.otherUser!
                } else {
                    sender = userCache.getUser(by: message.prefix!.nickname!)
                }
                
                guard sender != nil else {
                    print("Could not identify the sender of a PRIVMSG")
                    break
                }
                
                let logEvent = MessageLogEvent(contents, sender: sender!, userCache: userCache)
                room!.log.append(logEvent)
                delegate?.recieved(logEvent: logEvent, for: room!)
            }
        
        case Command.Reply.NAMREPLY:
            if message.target.count != 2 {
                print("Error parsing NAMREPLY")
                break
            }
            
            let channelName = message.target[1]
            
            guard let room = roomFrom(name: channelName) else {
                print("Got a list of users in a room, but did not have data on the room!")
                break
            }
            
            guard let nicknames = message.parameters?.components(separatedBy: " ") else {
                print("Did not recieve a list of users during NAMREPLY")
                break
            }
            
            userCache.parse(userList: nicknames, for: room)
            
        case Command.Reply.ENDOFNAMES:
            if message.target.count < 1 {
                break
            }
            
            let roomName = message.target[0]
            guard let room = roomFrom(name: roomName) else {
                break
            }
            
            room.hasCompleteUsersList = true
            room.sortUsers()
            delegate?.finishedReadingUserList(room)
            
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
            guard let user = userCache.getUser(by: nick) else {
                print("Could not find the User for which to log the quit message for")
                break
            }
            
            userCache.handleQuit(user: user)
            
        case Command.Reply.WHOISUSER:
            guard message.target.count == 4, let realname = message.parameters else {
                break
            }
            
            let nickname = message.target[0]
            var username = message.target[1]
            let hostname = message.target[2]
            
            // Take the tilde off the username
            if username.characters.first == "~" {
                username.remove(at: username.startIndex)
            }
            
            let user = userCache.getOrCreateUser(nickname: nickname)
            
            user.username = username
            user.host = hostname
            user.realname = realname
            
        case Command.Reply.WHOISSERVER:
            guard message.target.count == 2 else {
                break
            }
            
            let user = userCache.getOrCreateUser(nickname: message.target[0])
            let server = message.target[1]
            user.servername = server
            
        case Command.Reply.WHOISOPERATOR:
            break
            
        case Command.Reply.WHOISIDLE:
            guard message.target.count == 3, let onlineInterval = Int(message.target[2]), let idleInterval = Int(message.target[1]) else {
                break
            }
            
            let user = userCache.getOrCreateUser(nickname: message.target[0])
            
            user.onlineTime = Date(timeIntervalSince1970: TimeInterval(onlineInterval))
            user.idleTime = Date(timeIntervalSinceNow: TimeInterval(-idleInterval))
            
        case Command.Reply.WHOISCHANNELS:
            guard message.target.count == 1, let param = message.parameters else {
                break
            }
            
            let user = userCache.getOrCreateUser(nickname: message.target[0])
            
            user.channelList = param.components(separatedBy: " ")
            
        case Command.Reply.WHOISHOST:
            guard message.target.count == 1, var param = message.parameters else {
                break
            }
            
            let user = userCache.getOrCreateUser(nickname: message.target[0])
            
            // Chop off the start
            guard let asteriskIndex = param.range(of: " *@")?.upperBound else {
                break
            }
            
            param = param[asteriskIndex ..< param.endIndex]
            
            let comp = param.components(separatedBy: " ")
            
            guard comp.count == 2 else {
                break
            }
            
            user.host = comp[0]
            user.ip = comp[1]
            
        case Command.Reply.WHOISACCOUNT:
            // Not useful
            break
            
        case Command.Reply.ENDOFWHOIS:
            guard message.target.count == 1 else {
                break
            }
            
            let user = userCache.getOrCreateUser(nickname: message.target[0])
            
            if user.awayMessage == nil {
                user.away = false
            }
            
            if user.class == nil {
                user.class = .Normal
            }
            
            delegate?.infoWasUpdated(user)
        
        case Command.Reply.AWAY:
            guard message.target.count == 1, let awayMessage = message.parameters else {
                break
            }
            
            let user = userCache.getOrCreateUser(nickname: message.target[0])
            
            user.awayMessage = awayMessage
            user.away = true
            
        default:
            print(message.message)
            print("Unimplemented command handle: \(message.command)")
        }
        
        socket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
    }
    
}
