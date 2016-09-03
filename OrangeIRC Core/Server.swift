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

public class Server: NSObject, AsyncSocketDelegate, NSCoding {
    
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
        
    }
    
    // MOTD support
    public var motd = ""
    public var finishedReadingMOTD = false
    
    public var log = [String]()
    
    public var delegate: ServerDelegate?
    
    public var isConnectingOrRegistering = false
    
    public var userBitmask = 0
    
    var socket: AsyncSocket?
    
    // Saved data
    public var host: String
    public var port: Int
    public var nickname: String
    public var username: String
    public var realname: String
    public var password = ""
    public var nickservPassword = ""
    public var rooms: [Room] = [Room]()
    public var autoJoin = false
    // End saved data
    
    public var encoding: String.Encoding
    
    public var isRegistered = false
    
    public init(host: String, port: Int, nickname: String, username: String, realname: String, encoding: String.Encoding) {
        self.host = host
        self.port = port
        self.nickname = nickname
        self.username = username
        self.realname = realname
        self.encoding = encoding
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
            let nickservPassword = coder.decodeObject(forKey: Coding.NickServPassword) as? String,
            let rooms = coder.decodeObject(forKey: Coding.Rooms) as? [Room] else {
                return nil
        }
        // According to the compiler, this will always succeed
        let port = coder.decodeInteger(forKey: Coding.Port)
        
        self.init(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: String.Encoding.utf8)
        
        self.rooms = rooms
        
        // This property is not restored by NSCoding
        for room in self.rooms {
            room.server = self
        }
        
        self.nickservPassword = nickservPassword
        self.autoJoin = coder.decodeBool(forKey: Coding.AutoJoin)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.host, forKey: Coding.Host)
        aCoder.encode(self.port, forKey: Coding.Port)
        aCoder.encode(self.nickname, forKey: Coding.Nickname)
        aCoder.encode(self.username, forKey: Coding.Username)
        aCoder.encode(self.realname, forKey: Coding.Realname)
        aCoder.encode(self.rooms, forKey: Coding.Rooms)
        aCoder.encode(self.nickservPassword, forKey: Coding.NickServPassword)
        aCoder.encode(self.autoJoin, forKey: Coding.AutoJoin)
    }
    
    public func connect() {
        self.socket = AsyncSocket(delegate: self)
        do {
            try self.socket?.connect(toHost: self.host, onPort: UInt16(self.port), withTimeout: TIMEOUT_CONNECT)
            self.isConnectingOrRegistering = true
            self.delegate?.startedConnecting(server: self)
        } catch {
            self.delegate?.didNotRespond(server: self)
        }
    }
    
    public func onSocket(_ sock: AsyncSocket!, willDisconnectWithError err: Error!) {
        
    }
    
    public func onSocket(_ sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        self.delegate?.connectedSucessfully(server: self)
        socket?.readData(to: AsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
        print("Connected to host: \(host)")
        // Send the NICK message
        if sock == self.socket {
            if self.password.isEmpty {
                self.sendNickMessage()
            } else {
                self.sendPassMessage()
            }
        }
    }
    
    public func onSocketDidDisconnect(_ sock: AsyncSocket!) {
        // We need to wait after QUIT is sent, as things are sent asyncronously
        self.isConnectingOrRegistering = false
        self.isRegistered = false
        self.finishedReadingMOTD = false
        self.motd = ""
        self.socket?.setDelegate(nil)
        self.socket = nil
        
        for room in rooms {
            room.isJoined = false
        }
        
        self.delegate?.didDisconnect(server: self)
    }
    
    public func onSocket(_ sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
        switch tag {
        case Tag.Normal:
            break
        case Tag.Pass:
            self.sendNickMessage()
        case Tag.Nick:
            self.sendUserMessage()
        case Tag.User:
            if !self.nickservPassword.isEmpty {
                self.sendNickServPassword()
            }
        default:
            break
        }
    }
    
    public func onSocket(_ sock: AsyncSocket!, didRead data: Data!, withTag tag: Int) {
        let strData = data.subdata(in: (0 ..< data.count))
        guard let string = String(bytes: strData, encoding: self.encoding), string.isEmpty == false else {
            return
        }
        
        do {
            self.log.append(string)
            let message = try Message(string)
            handle(message: message)
        } catch {
            print("Failed to parse message: \(string)")
            socket?.readData(to: AsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
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
    
    public func disconnect() {
        write(string: Command.QUIT)
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
