//
//  Server.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation
import CocoaAsyncSocket

open class Server: NSObject, GCDAsyncSocketDelegate, NSCoding {
    
    let TIMEOUT_CONNECT = TimeInterval(30)
    let TIMEOUT_NONE = TimeInterval(-1)
    let CRLF = "\r\n"
    
    // NSCoding keys extracted to here so to avoid typos causing bugs
    struct Coding {
        
        static let Host = "Host"
        static let Alias = "Alias"
        static let Port = "Port"
        static let Nickname = "Nickname"
        static let Username = "Username"
        static let Realname = "Realname"
        static let Rooms = "Rooms"
        static let NickServPassword = "NickServPassword"
        static let AutoJoin = "AutoJoin"
        
    }
    
    // MOTD support
    open var motd: String?
    
    open var log = [Message]()
    
    public typealias ListChannel = (name: String, users: Int, topic: String?)
    // Call fetchChannelList() to populate
    open var channelListCache = [ListChannel]()
    
    open var delegate: ServerDelegate?
    
    open var isConnectingOrRegistering = false
    
    open var userBitmask: UInt8 = 0
    
    var socket: GCDAsyncSocket?
    
    open var isConnected: Bool {
        if let socket = socket {
            return socket.isConnected
        } else {
            return false
        }
    }
    
    open var displayName: String {
        return alias == nil ? host : alias!
    }
    
    // Saved data
    open var host: String
    open var alias: String?
    open var port: Int
    open var nickname: String
    open var username: String
    open var realname: String
    open var password = ""
    open var nickservPassword = ""
    open var autoJoin = false
    open var rooms = [Room]()
    // End saved data
    
    open var roomsFlaggedForAutoJoin = [String]()
    
    open var encoding: String.Encoding
    
    open var isRegistered = false
    
    // Used for reconnect functionality
    private var connectOnDisconnect = false
    
    // Used because the NickServ failed attempts notice comes in two NOTICEs
    var lastSentNickServFailedAttempts = -1
    
    var userCache: UserCache = UserCache()
    
    public init(host: String, port: Int, nickname: String, username: String, realname: String, encoding: String.Encoding) {
        self.host = host
        self.port = port
        self.nickname = nickname
        self.username = username
        self.realname = realname
        self.encoding = encoding
        super.init()
        userCache.server = self
    }
    
    public convenience init(host: String, port: Int, nickname: String, username: String, realname: String, encoding: String.Encoding, password: String) {
        self.init(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: encoding)
        self.password = password
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let host = coder.decodeObject(forKey: Coding.Host) as? String,
            let nickname = coder.decodeObject(forKey: Coding.Nickname) as? String,
            let username = coder.decodeObject(forKey: Coding.Username) as? String,
            let realname = coder.decodeObject(forKey: Coding.Realname) as? String,
            let nickservPassword = coder.decodeObject(forKey: Coding.NickServPassword) as? String else {
                return nil
        }
        // According to the compiler, this will always succeed
        let port = coder.decodeInteger(forKey: Coding.Port)
        
        self.init(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: String.Encoding.utf8)
        
        // This property is not restored by NSCoding
        for room in self.rooms {
            room.server = self
        }
        
        self.nickservPassword = nickservPassword
        self.autoJoin = coder.decodeBool(forKey: Coding.AutoJoin)
        
        if let rooms = coder.decodeObject(forKey: Coding.Rooms) as? [Room] {
            self.rooms = rooms
        }
        
        for room in self.rooms {
            room.server = self
        }
        
        alias = coder.decodeObject(forKey: Coding.Alias) as? String
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(host, forKey: Coding.Host)
        aCoder.encode(alias, forKey: Coding.Alias)
        aCoder.encode(port, forKey: Coding.Port)
        aCoder.encode(nickname, forKey: Coding.Nickname)
        aCoder.encode(username, forKey: Coding.Username)
        aCoder.encode(realname, forKey: Coding.Realname)
        aCoder.encode(nickservPassword, forKey: Coding.NickServPassword)
        aCoder.encode(autoJoin, forKey: Coding.AutoJoin)
        aCoder.encode(rooms, forKey: Coding.Rooms)
    }
    
    open func connect() {
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        // We like new protocols
        self.socket!.isIPv4PreferredOverIPv6 = false
        
        do {
            try self.socket?.connect(toHost: self.host, onPort: UInt16(self.port), withTimeout: TIMEOUT_CONNECT)
            self.isConnectingOrRegistering = true
            self.delegate?.startedConnecting(self)
        } catch {
            self.delegate?.didNotRespond(self)
        }
    }
    
    open func disconnect() {
        write(string: Command.QUIT)
    }
    
    /*
 
      FIXME: This should be done with blocks instead of booleans.
 
      Example: disconnect(completion: <closure>)
 
    */
    open func reconnect() {
        connectOnDisconnect = true
        disconnect()
    }
    
    func reset() {
        let notifyDelegate = isConnectingOrRegistering || isRegistered
        
        self.isConnectingOrRegistering = false
        self.isRegistered = false
        self.motd = nil
        self.socket?.setDelegate(nil, delegateQueue: nil)
        self.socket = nil
        
        for room in rooms {
            if let channel = room as? Channel {
                channel.isJoined = false
            }
        }
        
        
        if notifyDelegate {
            // Only tell the delegate that we disconnected if we were connected
            self.delegate?.didDisconnect(self)
        }
        
        if connectOnDisconnect {
            connect()
            connectOnDisconnect = false
        }
    }
    
    func sendPassMessage() {
        print("Sent PASS message: \(self.host)")
        self.write(string: "\(Command.PASS) \(self.password)", with: Tag.Pass)
    }
    
    // Doesn't send with a tag, part of the API
    open func sendPassword() {
        write(string: "\(Command.PASS) \(password)")
    }
    
    // Same as above
    open func sendNick() {
        write(string: "\(Command.NICK) \(nickname)")
    }
    
    func sendNickMessage() {
        print("Sent NICK message: \(self.host)")
        self.write(string: "\(Command.NICK) \(self.nickname)", with: Tag.Nick)
    }
    
    func sendUserMessage() {
        print("Sent USER message: \(self.host)")
        self.write(string: "\(Command.USER) \(self.username) \(self.userBitmask) * :\(self.realname)", with: Tag.User)
    }
    
    open func sendNickServPassword() {
        self.write(string: "\(Command.PRIVMSG) \(Command.Services.NickServ) :\(Command.IDENTIFY) \(self.nickservPassword)", with: Tag.NickServPassword)
    }
    
    func write(string: String, with tag: Int) {
        var appendedString = "\(string)\(CRLF)"
        let bytes = [UInt8](appendedString.utf8)
        self.socket?.write(Data(bytes: bytes), withTimeout: TIMEOUT_NONE, tag: tag)
    }
    
    func write(string: String) {
        var appendedString = "\(string)\(CRLF)"
        let bytes = [UInt8](appendedString.utf8)
        self.socket?.write(Data(bytes: bytes), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
    }
    
    open func fetchInfo(_ user: User) {
        user.awayMessage = nil
        user.away = nil
        write(string: "\(Command.WHOIS) \(user.nick)")
    }
    
    open func fetchChannelList() {
        channelListCache.removeAll()
        write(string: "\(Command.LIST)")
    }
    
    open func prepareForBackground() {
        if let socket = socket {
            if socket.isConnected {
                socket.perform {
                    if !socket.enableBackgroundingOnSocket() {
                        print("Failed to enable backgrounding for server: \(self.host)")
                    }
                }
            }
        }
    }
    
}
