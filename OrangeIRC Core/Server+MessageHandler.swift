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
    
    func reclaimTimerDelegate(aTimer: Timer) {
        self.write(string: "\(Command.NICK) \(self.preferredNickname)")
    }
    
    func handle(message: Message) {
        
        switch message.command {
        case Command.Reply.WELCOME:
            self.isConnectingOrRegistering = false
            self.delegate?.registeredSuccessfully(self)
            self.isRegistered = true
            for room in rooms {
                if let channel = room as? Channel {
                    if channel.joinOnConnect {
                        // Completes the feature of the Connect and Join button
                        join(channel: channel.name, key: channel.key)
                        channel.joinOnConnect = false
                    } else if channel.autoJoin && !channel.isJoined {
                        // Completes the room autojoin feature
                        join(channel: channel.name, key: channel.key)
                    }
                }

            }
            
            // Start the reclaim timer if necessary
            if nickname != preferredNickname {
                
                reclaimTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(reclaimTimerDelegate(aTimer:)), userInfo: nil, repeats: true)
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
        
        case Command.NICK:
            // Nickname change
            guard let oldNick = message.prefix?.nickname, let newNick = message.parameters else {
                break
            }
            
            if oldNick == nickname {
                if newNick == preferredNickname && reclaimTimer != nil {
                    // Our nickname change request was accepted
                    reclaimTimer!.invalidate()
                    reclaimTimer = nil
                }
                // The server gave us a different nickname we didn't ask for
                // Or because we authenticated with NickServ
                nickname = newNick
                userCache.me.nick = nickname
            }
            
            if let user = userCache.getUser(by: oldNick) {
                user.nick = newNick
                
                for channelData in user.channels {
                    if let chan = channelFrom(name: channelData.name) {
                        let logEvent = UserNickChangeLogEvent(sender: user, room: chan, oldNick: oldNick, newNick: newNick)
                        chan.log.append(logEvent)
                        delegate?.received(logEvent: logEvent, for: chan)
                    }
                }
            }
            
        case Command.ERROR:
            guard let errorMessage = message.parameters else {
                print("Failed to get an ERROR message")
                delegate?.received(error: localized("UNKNOWN_ERROR"), on: self)
                break
            }
            
            // Hide the ERROR some servers send when the client sends QUIT
            if errorMessage.contains("Quit: ") || errorMessage.contains(":Closing Link:") {
                break
            }
            
            delegate?.received(error: errorMessage, on: self)
            
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
            
            let room = getOrAddChannel(channelName)
            
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
            
            room.sortUsers()
            
            ServerManager.shared.saveData()
            
            userCache.handleJoin(user: user, channel: room)
        
        case Command.PART:
            guard let nick = message.prefix?.nickname else {
                print("Recieved a PART message without a prefix")
                break
            }
            
            let roomName = message.target[0]
            
            guard let room = channelFrom(name: roomName) else {
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
                    delegate?.received(notice: message, sender: servername, on: self)
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
                    self.delegate?.received(notice: noticeMessage, sender: sender, on: self)
                }
            }
            
        case Command.PING:
            self.write(string: "\(Command.PONG) :\(message.parameters!)")
        
        case Command.MODE:
            guard let modeString = message.parameters, message.target.count == 1 else {
                break
            }
            
            if message.target[0] == nickname {
                mode.update(with: modeString)
            }
            
        case Command.Reply.YOURID:
            // Useless
            break
        
        case Command.KICK:
            guard message.target.count == 2 else {
                break
            }
            
            guard let senderNick = message.prefix?.nickname else {
                print("Couldn't identify the sender of a KICK")
                break
            }
            
            guard let room = channelFrom(name: message.target[0]) else {
                print("Couldn't find channel for KICK")
                break
            }
            
            let sender = userCache.getOrCreateUser(nickname: senderNick)
            let receiver = userCache.getOrCreateUser(nickname: message.target[1])
            
            let logEvent = KickLogEvent(sender: sender, receiver: receiver, room: room)
            room.log.append(logEvent)
            delegate?.received(logEvent: logEvent, for: room)
            
            // Set the room as left if we were kicked
            if receiver == userCache.me {
                room.isJoined = false
                NotificationCenter.default.post(name: Notifications.UserInfoDidChange, object: room)
                delegate?.kicked(server: self, room: room, sender: sender)
            }
            
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
            motd = motd == nil ? parameters : "\(motd!)\n\(parameters)"
            
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
            guard let channel = channelFrom(name: channelName) else {
                break
            }
            channel.hasTopic = false
            
        case Command.Reply.TOPIC:
            let channelName = message.target[0]
            guard let channel = channelFrom(name: channelName) else {
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
            
            
            let isPrivate = !Channel.CHANNEL_PREFIXES.characterIsMember(roomName.utf16.first!)
            
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
                if isPrivate {
                    var privateRoom: Room!
                    if let existingRoom = privateMessageFrom(user: userCache.getOrCreateUser(nickname: message.prefix!.nickname!)) {
                        privateRoom = existingRoom
                    } else {
                        privateRoom = startPrivateMessageSession(message.prefix!.nickname!)
                    }
                    let logEvent = MessageLogEvent(contents: contents, sender: userCache.getOrCreateUser(nickname: message.prefix!.nickname!), room: privateRoom)
                    privateRoom.log.append(logEvent)
                    delegate?.received(logEvent: logEvent, for: privateRoom)
                } else {
                    if let sender = userCache.getUser(by: message.prefix!.nickname!) {
                        if let room = channelFrom(name: roomName) {
                            let logEvent = MessageLogEvent(contents: contents, sender: sender, room: room)
                            room.log.append(logEvent)
                            delegate?.received(logEvent: logEvent, for: room)
                        }
                    }
                }
            }
        
        case Command.Reply.NAMREPLY:
            if message.target.count != 2 {
                print("Error parsing NAMREPLY")
                break
            }
            
            let channelName = message.target[1]
            
            guard let room = channelFrom(name: channelName) else {
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
            guard let room = channelFrom(name: roomName) else {
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
            
        case Command.Reply.LISTSTART:
            // Clear the old ones
            channelListCache.removeAll()
            
        case Command.Reply.LIST:
            guard message.target.count == 2 else {
                print("Invalid LIST reply target length")
                break
            }
            
            let name = message.target[0]
            
            guard let userCount = Int(message.target[1]) else {
                print("Invalid LIST reply users count")
                break
            }
            
            channelListCache.append((name: name, users: userCount, topic: message.parameters))
            
            // Only call this for every 10th update, to avoid spam
            if channelListCache.count % 100 == 0 {
                delegate?.chanlistUpdated(self)
            }
            
        case Command.Reply.LISTEND:
            delegate?.finishedReadingChanlist(self)
        
        case Command.Reply.CHANNEL_URL:
            guard message.target.count == 0, let urlString = message.parameters else {
                break
            }
            
            if let channel = channelFrom(name: message.target[0]) {
                channel.url = URL(string: urlString)
            }
            
        case Command.Error.TOOMANYTARGETS,
             Command.Error.NOSUCHSERVICE,
             Command.Error.NOORIGIN,
             Command.Error.NORECIPIENT,
             Command.Error.NOTEXTTOSEND,
             Command.Error.NOTOPLEVEL,
             Command.Error.WILDTOPLEVEL,
             Command.Error.BADMASK,
             Command.Error.UNKNOWNCOMMAND:
            // We likely won't be encountering these
            break
        
        case Command.Error.NOSUCHNICK:
            // No such nickname or channel
            if message.target.count == 1 {
                delegate?.noSuch(nick: message.target[0], self)
            }
            
        case Command.Error.NOSUCHSERVER:
            // No such server
            if message.target.count == 1 {
                delegate?.noSuch(server: message.target[0], self)
            }
            
        case Command.Error.NOSUCHCHANNEL:
            // No such channel
            if message.target.count == 1 {
                delegate?.noSuch(channel: message.target[0], self)
            }
            
        case Command.Error.CANNOTSENDTOCHAN:
            if message.target.count == 1 {
                delegate?.cannotSendTo(channel: message.target[0], self)
            }
            
        case Command.Error.TOOMANYCHANNELS:
            delegate?.tooManyChannels(self)
            
        case Command.Error.PASSWDMISMATCH:
            // We need a password
            delegate?.serverPasswordNeeded(self)
        
        case Command.Error.BADCHANNELKEY:
            guard message.target.count == 1 else {
                break
            }
            
            if let channel = channelFrom(name: message.target[0]) {
                if channel.key == nil {
                    delegate?.keyNeeded(channel: channel, on: self)
                } else {
                    delegate?.keyIncorrect(channel: channel, on: self)
                }
            }
        
        case Command.Error.INVITEONLYCHAN:
            guard message.target.count == 1 else {
                break
            }
            
            guard let channel = channelFrom(name: message.target[0]) else {
                break
            }
            
            delegate?.inviteOnly(server: self, channel: channel)
            
        case Command.Error.BANNEDFROMCHAN:
            guard message.target.count == 1 else {
                break
            }
            
            guard let channel = channelFrom(name: message.target[0]) else {
                break
            }
            
            delegate?.banned(server: self, channel: channel)
        
        case Command.Error.NICKNAMEINUSE:
            if isConnectingOrRegistering {
                // Use an alternate nickname and try again in 30 seconds
                if appendedUnderscoreCount < 5 {
                    appendedUnderscoreCount += 1
                    nickname = "\(nickname)_"
                    userCache.me.nick = nickname
                    write(string: "\(Command.NICK) \(nickname)")
                }
            }
            
        case Command.Error.NONICKNAMEGIVEN:
            print("NNONICKNAMEGIVEN: Is preferredNickname nil?")
            
        default:
            print(message.message)
            print("Unimplemented command handle: \(message.command)")
        }
        
        socket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
    }
    
}
