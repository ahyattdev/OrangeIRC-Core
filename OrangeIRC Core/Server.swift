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

public class Server: AnyObject, AsyncSocketDelegate {
    
    // MOTD support
    public var motd = ""
    public var finishedReadingMOTD = false
    
    public var log = [String]()
    
    public var rooms = [Room]()
    
    public var delegate: ServerDelegate?
    
    public var isConnectingOrRegistering = false
    
    var socket: AsyncSocket?
    
    public var host: String
    
    public var port: Int
    
    public var userBitmask = 0
    
    public var nickname: String
    public var username: String
    public var realname: String
    public var password = ""
    
    public var encoding: String.Encoding
    
    public var partialMessage: String?
    
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
    
    public func onSocket(_ sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
        switch tag {
        case Tag.Normal:
            break
        case Tag.Pass:
            self.sendNickMessage()
        case Tag.Nick:
            self.sendUserMessage()
        default:
            break
        }
    }
    
    public func onSocket(_ sock: AsyncSocket!, didRead data: Data!, withTag tag: Int) {
        let strData = data.subdata(in: (0 ..< data.count))
        guard let string = String(bytes: strData, encoding: self.encoding) where string.isEmpty == false else {
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
    
    public func disconnect() {
        write(string: Command.QUIT)
        self.socket = nil
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
