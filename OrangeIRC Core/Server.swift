//
//  Server.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation
import CocoaAsyncSocket

/// An all-capable IRC server client
open class Server: NSObject, GCDAsyncSocketDelegate, NSCoding {
    
    /// Server connection timeout
    open var connectionTimeout = TimeInterval(30)
    /// Timeout value representing no timeout
    open let noTimeout = TimeInterval(-1)
    internal let crlf = "\r\n"
    
    // NSCoding keys extracted to here so to avoid typos causing bugs
    fileprivate struct Coding {
        
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
    
    /// Message Of The Day string
    /// Populated once the server sends it
    open var motd: String?
    
    /// The client console log
    open var console = [ConsoleEntry]()
    /// Client console log delegate
    open var consoleDelegate: ConsoleDelegate?
    
    /// Wrapper type for data returned by LIST
    public typealias ListChannel = (name: String, users: Int, topic: String?)
    
    /// Cache of IRC channel list.
    /// Call fetchChannelList() to populate.
    open var channelListCache = [ListChannel]()
    
    /// The delegate of this server client
    open var delegate: ServerDelegate?
    
    /// When the client has attempted to connect but isn't fully connected yet.
    /// In other words, it is still connecting.
    internal(set) open var isConnectingOrRegistering = false
    
    /// The IRC user bitmask
    internal(set) open var userBitmask: UInt8 = 0
    
    internal var socket: GCDAsyncSocket?
    
    internal var reclaimTimer: Timer?
    
    /// IRC client connection status
    open var isConnected: Bool {
        if let socket = socket {
            return socket.isConnected
        } else {
            return false
        }
    }
    
    /// A human friendly name of the server
    open var displayName: String {
        return alias == nil ? host : alias!
    }
    
    // Saved data
    
    /// Server hostname
    ///
    /// **This is saved by `NSCoding`***.
    open var host: String
    /// Server alias, usually a user-defined name for the server
    ///
    /// **This is saved by `NSCoding`***.
    open var alias: String?
    /// Server port, optional
    ///
    /// **This is saved by `NSCoding`***.
    open var port: Int
    /// The user’s prefered nickname, not necessarily the one given
    /// by the server.
    ///
    /// **This is saved by `NSCoding`***.
    open var preferredNickname: String
    /// Client username
    ///
    /// **This is saved by `NSCoding`***.
    open var username: String
    /// Client realname
    ///
    /// **This is saved by `NSCoding`***.
    open var realname: String
    /// Server password, optional
    ///
    /// **This is saved by `NSCoding`***.
    open var password = ""
    /// Nickname password, optional
    ///
    /// **This is saved by `NSCoding`***.
    open var nickservPassword = ""
    /// Automatically join rooms on connection
    ///
    /// **This is saved by `NSCoding`***.
    open var autoJoin = false
    /// Rooms that this client is in
    ///
    /// **This is saved by `NSCoding`***.
    open var rooms = [Room]()
    
    // End saved data
    
    /// The nickname of the client
    internal(set) open var nickname: String
    
    internal var appendedUnderscoreCount = 0
    
    /// Rooms that will automatically be joined
    open var roomsFlaggedForAutoJoin = [String]()
    
    /// Server encoding, defaults to UTF-8
    open var encoding: String.Encoding
    
    /// Client registration status
    internal(set) open var isRegistered = false
    
    // Used for reconnect functionality
    private var connectOnDisconnect = false
    
    // Used because the NickServ failed attempts notice comes in two NOTICEs
    internal var lastSentNickServFailedAttempts = -1
    
    internal var userCache: UserCache = UserCache()
    
    internal var mode = UserMode()
    
    public init(host: String, port: Int, nickname: String, username: String, realname: String, encoding: String.Encoding) {
        self.host = host
        self.port = port
        self.preferredNickname = nickname
        self.nickname = preferredNickname
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
            let preferredNickname = coder.decodeObject(forKey: Coding.Nickname) as? String,
            let username = coder.decodeObject(forKey: Coding.Username) as? String,
            let realname = coder.decodeObject(forKey: Coding.Realname) as? String,
            let nickservPassword = coder.decodeObject(forKey: Coding.NickServPassword) as? String else {
                return nil
        }
        // According to the compiler, this will always succeed
        let port = coder.decodeInteger(forKey: Coding.Port)
        
        self.init(host: host, port: port, nickname: preferredNickname, username: username, realname: realname, encoding: String.Encoding.utf8)
        
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
        aCoder.encode(preferredNickname, forKey: Coding.Nickname)
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
            try self.socket?.connect(toHost: self.host, onPort: UInt16(self.port), withTimeout: connectionTimeout)
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
    
    internal func reset() {
        let notifyDelegate = isConnectingOrRegistering || isRegistered
        
        isConnectingOrRegistering = false
        isRegistered = false
        motd = nil
        socket?.setDelegate(nil, delegateQueue: nil)
        socket = nil
        mode = UserMode()
        appendedUnderscoreCount = 0
        
        for room in rooms {
            if let channel = room as? Channel {
                channel.isJoined = false
            }
        }
        
        
        if notifyDelegate {
            // Only tell the delegate that we disconnected if we were connected
            delegate?.didDisconnect(self)
        }
        
        if connectOnDisconnect {
            connect()
            connectOnDisconnect = false
        }
    }
    
    internal func sendPassMessage() {
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
    
    internal func sendNickMessage() {
        print("Sent NICK message: \(self.host)")
        nickname = preferredNickname
        self.write(string: "\(Command.NICK) \(self.nickname)", with: Tag.Nick)
    }
    
    internal func sendUserMessage() {
        print("Sent USER message: \(self.host)")
        self.write(string: "\(Command.USER) \(self.username) \(self.userBitmask) * :\(self.realname)", with: Tag.User)
    }
    
    open func sendNickServPassword() {
        self.write(string: "\(Command.PRIVMSG) \(Command.Services.NickServ) :\(Command.IDENTIFY) \(self.nickservPassword)", with: Tag.NickServPassword)
    }
    
    internal func write(string: String, with tag: Int) {
        var appendedString = "\(string)\(crlf)"
        let bytes = [UInt8](appendedString.utf8)
        let entry = ConsoleEntry(text: string, sender: .Client)
        add(consoleEntry: entry)
        self.socket?.write(Data(bytes: bytes), withTimeout: noTimeout, tag: tag)
    }
    
    internal func write(string: String) {
        var appendedString = "\(string)\(crlf)"
        let bytes = [UInt8](appendedString.utf8)
        let entry = ConsoleEntry(text: string, sender: .Client)
        add(consoleEntry: entry)
        self.socket?.write(Data(bytes: bytes), withTimeout: noTimeout, tag: Tag.Normal)
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
        #if os(iOS) || os(tvOS)
        if let socket = socket {
            if socket.isConnected {
                socket.perform {
                    if !socket.enableBackgroundingOnSocket() {
                        print("Failed to enable backgrounding for server: \(self.host)")
                    }
                }
            }
        }
        #endif
    }
    
    internal func add(consoleEntry: ConsoleEntry) {
        console.append(consoleEntry)
        consoleDelegate?.newConsoleEntry(server: self, entry: consoleEntry)
    }
    
}
