//
//  Server.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation
import CocoaAsyncSocket

let TIMEOUT_CONNECT = TimeInterval(30)
let TIMEOUT_NONE = TimeInterval(-1)
let CRLF = "\r\n"

public class Server: NSObject, GCDAsyncSocketDelegate, NSCoding {
    
    public static let ValidChannelPrefixes = NSCharacterSet(charactersIn: "&#!+")
    
    // NSCoding keys extracted to here so to avoid typos causing bugs
    struct Coding {
        
        static let Host = "Host"
        static let Port = "Port"
        static let Nickname = "Nickname"
        static let Username = "Username"
        static let Realname = "Realname"
        static let Rooms = "Rooms"
        static let NickServPassword = "NickServPassword"
        static let AutoJoin = "AutoJoin"
        static let UUID = "UUID"
        
    }
    
    // MOTD support
    public var motd = ""
    public var finishedReadingMOTD = false
    
    public var log = [String]()
    public var rooms: [Room] = [Room]()
    
    public var delegate: ServerDelegate?
    
    public var isConnectingOrRegistering = false
    
    public var userBitmask = 0
    
    var socket: GCDAsyncSocket?
    
    // Saved data
    public var host: String
    public var port: Int
    public var nickname: String
    public var username: String
    public var realname: String
    public var password = ""
    public var nickservPassword = ""
    public var autoJoin = false
    public var uuid: UUID
    // End saved data
    
    public var roomsFlaggedForAutoJoin = [String]()
    
    public var encoding: String.Encoding
    
    public var isRegistered = false
    
    // Used for reconnect functionality
    private var connectOnDisconnect = false
    
    public init(host: String, port: Int, nickname: String, username: String, realname: String, encoding: String.Encoding) {
        self.host = host
        self.port = port
        self.nickname = nickname
        self.username = username
        self.realname = realname
        self.encoding = encoding
        uuid = UUID()
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
        
        guard let uuid = coder.decodeObject(forKey: Coding.UUID) as? UUID else {
            return nil
        }
        self.uuid = uuid
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(host, forKey: Coding.Host)
        aCoder.encode(port, forKey: Coding.Port)
        aCoder.encode(nickname, forKey: Coding.Nickname)
        aCoder.encode(username, forKey: Coding.Username)
        aCoder.encode(realname, forKey: Coding.Realname)
        aCoder.encode(nickservPassword, forKey: Coding.NickServPassword)
        aCoder.encode(autoJoin, forKey: Coding.AutoJoin)
        aCoder.encode(uuid, forKey: Coding.UUID)
    }
    
    public func connect() {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try self.socket?.connect(toHost: self.host, onPort: UInt16(self.port), withTimeout: TIMEOUT_CONNECT)
            self.isConnectingOrRegistering = true
            self.delegate?.startedConnecting(server: self)
        } catch {
            self.delegate?.didNotRespond(server: self)
        }
    }
    
    public func disconnect() {
        write(string: Command.QUIT)
    }
    
    /*
 
      FIXME: This should be done with blocks instead of booleans.
 
      Example: disconnect(completion: <closure>)
 
    */
    public func reconnect() {
        connectOnDisconnect = true
        disconnect()
    }
    
    func reset() {
        self.isConnectingOrRegistering = false
        self.isRegistered = false
        self.finishedReadingMOTD = false
        self.motd = ""
        self.socket?.setDelegate(nil, delegateQueue: nil)
        self.socket = nil
        
        for room in rooms {
            room.isJoined = false
        }
        
        self.delegate?.didDisconnect(server: self)
        
        if connectOnDisconnect {
            connect()
            connectOnDisconnect = false
        }
    }
    
    func sendPassMessage() {
        print("Sent PASS message: \(self.host)")
        self.write(string: "\(Command.PASS) \(self.password)", with: Tag.Pass)
    }
    
    func sendNickMessage() {
        print("Sent NICK message: \(self.host)")
        self.write(string: "\(Command.NICK) \(self.nickname)", with: Tag.Nick)
    }
    
    func sendUserMessage() {
        print("Sent USER message: \(self.host)")
        self.write(string: "\(Command.USER) \(self.username) \(self.userBitmask) * :\(self.realname)", with: Tag.User)
    }
    
    public func sendNickServPassword() {
        if !self.nickservPassword.isEmpty {
            self.write(string: "\(Command.PRIVMSG) \(Command.Services.NickServ) :\(Command.IDENTIFY) \(self.nickservPassword)", with: Tag.NickServPassword)
        }
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
    
}
