//
//  Server.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation
import CocoaAsyncSocket

/// Wrapper type for data returned by LIST.
public typealias ListChannel = (name: String, users: Int, topic: String?)

/// An all-capable IRC server client.
///
/// To handle events, such as a successful connection or a channel join, see
/// `ServerDelegate` and `Server.delegate`.
open class Server: NSObject, GCDAsyncSocketDelegate, NSCoding {
    
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
    
    // MARK: Constants
    
    /// Timeout value representing no timeout.
    open let noTimeout = TimeInterval(-1)
    
    internal let crlf = "\r\n"
    
    // MARK: Client settings
    
    // Saved data
    
    /// Server hostname.
    ///
    /// *This is saved by `NSCoding`*.
    open var host: String
    /// Server alias, usually a user-defined name for the server.
    ///
    /// *This is saved by `NSCoding`*.
    open var alias: String?
    /// Server port, optional.
    ///
    /// *This is saved by `NSCoding`*.
    open var port: Int
    /// The user’s prefered nickname, not necessarily the one given
    /// by the server.
    ///
    /// *This is saved by `NSCoding`*.
    open var preferredNickname: String
    /// Client username.
    ///
    /// *This is saved by `NSCoding`*.
    open var username: String
    /// Client realname.
    ///
    /// *This is saved by `NSCoding`*.
    open var realname: String
    /// Server password, optional.
    ///
    /// *This is saved by `NSCoding`*.
    open var password = ""
    /// Nickname password, optional
    ///
    /// *This is saved by `NSCoding`*.
    open var nickservPassword = ""
    /// Automatically join rooms on connection.
    ///
    /// *This is saved by `NSCoding`*.
    open var autoJoin = false
    /// Rooms that this client is in.
    ///
    /// *This is saved by `NSCoding`*.
    open var rooms = [Room]()
    
    // End saved data
    
    /// The delegate of this server client.
    open var delegate: ServerDelegate?
    
    /// Client console log delegate.
    open var consoleDelegate: ConsoleDelegate?
    
    /// Server connection timeout.
    open var connectionTimeout = TimeInterval(30)
    
    /// Rooms that will automatically be joined.
    open var roomsFlaggedForAutoJoin = [String]()
    
    /// Server encoding, defaults to UTF-8.
    open var encoding: String.Encoding
    
    // MARK: Session data
    
    /// IRC client connection status.
    open var isConnected: Bool {
        if let socket = socket {
            return socket.isConnected
        } else {
            return false
        }
    }
    
    /// A human friendly name of the server.
    open var displayName: String {
        return alias == nil ? host : alias!
    }
    
    /// The nickname of the client.
    internal(set) open var nickname: String
    
    /// Message Of The Day string, populated once the server sends it.
    internal(set) open var motd: String?
    
    /// The client console log.
    internal(set) open var console = [ConsoleEntry]()
    
    /// Cache of IRC channel list.
    /// Call fetchChannelList() to populate.
    internal(set) open var channelListCache = [ListChannel]()
    
    /// When the client has attempted to connect but isn't fully connected yet.
    /// In other words, it is still connecting.
    internal(set) open var isConnectingOrRegistering = false
    
    /// The IRC user bitmask.
    internal(set) open var userBitmask: UInt8 = 0
    
    /// Client registration status.
    internal(set) open var isRegistered = false
    
    
    // Used because the NickServ failed attempts notice comes in two NOTICEs.
    internal var lastSentNickServFailedAttempts = -1
    
    internal var userCache: UserCache = UserCache()
    
    internal var mode = UserMode()
    
    // Used for reconnect functionality.
    internal var connectOnDisconnect = false
    
    internal var socket: GCDAsyncSocket?
    
    internal var reclaimTimer: Timer?
    
    internal var appendedUnderscoreCount = 0
    
    // MARK: Creating an IRC server client
    
    /// Create a client for an IRC server with the essential settings.
    ///
    /// - Parameters:
    ///   - host: Server hostname
    ///   - port: Server port
    ///   - nickname: Client preferred nickname
    ///   - username: Client username
    ///   - realname: Client real name
    ///   - encoding: Server connection encoding, defaults to UTF-8
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
    
    /// Create a client for an IRC server with the essential settings and a
    /// password.
    ///
    /// - Parameters:
    ///   - host: Server hostname
    ///   - port: Server port
    ///   - nickname: Client preferred nickname
    ///   - username: Client username
    ///   - realname: Client real name
    ///   - encoding: Server connection encoding, defaults to UTF-8
    ///   - password: Server password
    public convenience init(host: String, port: Int, nickname: String, username: String, realname: String, encoding: String.Encoding, password: String) {
        self.init(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: encoding)
        self.password = password
    }
    
    /// Create a client for an IRC server using the `NSCoding` APIs.
    ///
    /// - Parameter coder: Has a client for an IRC server encoded
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
    
    /// Encode a client for an IRC server using the `NSCoding` APIs.
    ///
    /// - Parameter aCoder: The coder to encode the client in
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
    
    // MARK: Connection state
    
    /// Initiates connection from the client to the server.
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
    
    /// Initiates graceful disconnection between the client and server.
    open func disconnect() {
        write(string: Command.QUIT)
    }
    
    /// Disconnects and reconnects from the server.
    open func reconnect() {
        // FIXME: This should be done with blocks instead of booleans
        // Example: disconnect(completion: <closure>)
        connectOnDisconnect = true
        disconnect()
    }
    
    // MARK: User identity and authentication
    
    /// Sends the server password.
    open func sendPassword() {
        // Doesn't send with a tag, part of the API
        write(string: "\(Command.PASS) \(password)")
    }
    
    /// Sends the user nickname (not preferred).
    open func sendNick() {
        // FIXME: Might need changes to work with preferred nickname
        write(string: "\(Command.NICK) \(nickname)")
    }
    
    /// Sends the NickServ nickname password.
    open func sendNickServPassword() {
        self.write(string: "\(Command.PRIVMSG) \(Command.Services.NickServ) :\(Command.IDENTIFY) \(self.nickservPassword)", with: Tag.NickServPassword)
    }
    
    // MARK: User data
    
    /// Fetches information on a user from the server.
    ///
    /// - Parameter user: The user to fetch information for.
    open func fetchInfo(_ user: User) {
        user.awayMessage = nil
        user.away = nil
        write(string: "\(Command.WHOIS) \(user.nick)")
    }
    
    // MARK: IRC channels
    
    /// Starts fetching the channel list from the server.
    open func fetchChannelList() {
        channelListCache.removeAll()
        write(string: "\(Command.LIST)")
    }
    
    /// Join an IRC channel.
    ///
    /// - Parameters:
    ///   - channel: Channel name
    ///   - key: Channel key, optional
    open func join(channel: String, key: String? = nil) {
        var stringToWrite = "\(Command.JOIN) \(channel)"
        // Append "#" if no other prefixes are detected
        if let first = channel.utf16.first {
            if !Channel.channelPrefixes.characterIsMember(first) {
                stringToWrite = "\(Command.JOIN) #\(channel)"
            }
        }
        
        if key != nil {
            stringToWrite = "\(stringToWrite) \(key!)"
        }
        
        write(string: stringToWrite)
    }
    
    /// Leave a channel.
    ///
    /// - Parameter channel: Channel name.
    open func leave(channel: String) {
        write(string: "\(Command.PART) \(channel)")
    }
    
    /// Check if a channel already exists in the client.
    ///
    /// - Parameter channelName: Channel name
    /// - Returns: Value indicating existence of channel
    internal func alreadyExists(_ channelName: String) -> Bool {
        for existingRoom in self.rooms {
            if let channel = existingRoom as? Channel {
                if channel.name == channelName {
                    return true
                }
            }
        }
        return false
    }
    
    /// Create a `Channel` from a channel name
    ///
    /// - Parameter name: Channel name
    /// - Returns: `Channel`
    internal func channelFrom(name: String) -> Channel? {
        for room in self.rooms {
            if let channel = room as? Channel {
                if channel.name == name {
                    return channel
                }
            }
        }
        return nil
    }
    
    /// Creates a private message room to a user
    ///
    /// - Parameter user: User to message
    /// - Returns: Private message room
    internal func privateMessageFrom(user: User) -> PrivateMessage? {
        for room in rooms {
            if let privateMessageRoom = room as? PrivateMessage {
                if privateMessageRoom.otherUser == user {
                    return privateMessageRoom
                }
            }
        }
        return nil
    }
    
    /// Gets a channel from a channel name. Creates it if it doesn’t exist
    /// already.
    ///
    /// - Parameter name: Channel name
    /// - Returns: `Channel`
    internal func getOrAddChannel(_ name: String) -> Channel {
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
    
    /// Starts a private message session with another user and message.
    ///
    /// The message is necessary because you can't start a private message
    /// session without a message, unlike creating channels.
    ///
    /// - Parameters:
    ///   - otherNick: The user to message
    ///   - message: The message to send
    internal func startPrivateMessageSession(_ otherNick: String, with message: String) {
        startPrivateMessageSession(otherNick)
        write(string: "\(Command.PRIVMSG) \(otherNick) :\(message)")
    }
    
    @discardableResult
    /// Starts a private message session with another user and message.
    ///
    /// - Parameter otherNick: The user to message
    /// - Returns: The resulting Room
    open func startPrivateMessageSession(_ otherNick: String) -> Room {
        // FIXME: Return PrivateMessage instead of Room?
        
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
    
    /// Deletes a room. If it is a `Channel` the client will also leave it.
    ///
    /// - Parameter room: The room to delete
    open func delete(room: Room) {
        
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
    
    // MARK: Utility
    
    /// Prepare this server for the app to enter the background.
    ///
    /// Does nothing on macOS.
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
    
    // Same as above
    
    internal func sendNickMessage() {
        print("Sent NICK message: \(self.host)")
        nickname = preferredNickname
        self.write(string: "\(Command.NICK) \(self.nickname)", with: Tag.Nick)
    }
    
    internal func sendUserMessage() {
        print("Sent USER message: \(self.host)")
        self.write(string: "\(Command.USER) \(self.username) \(self.userBitmask) * :\(self.realname)", with: Tag.User)
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
    
    internal func add(consoleEntry: ConsoleEntry) {
        console.append(consoleEntry)
        consoleDelegate?.newConsoleEntry(server: self, entry: consoleEntry)
    }
    
}
