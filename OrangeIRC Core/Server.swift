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

public class Server: AnyObject, GCDAsyncSocketDelegate {
    
    var delegate: ServerDelegate?
    
    var socket: GCDAsyncSocket?
    
    var host: String
    
    var port: Int
    
    var userBitmask = 0
    
    var nickname: String
    var username: String
    var realname: String
    var password = ""
    
    var encoding: String.Encoding
    
    var partialMessage: String?
    
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
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try self.socket?.connect(toHost: self.host, onPort: UInt16(self.port), withTimeout: TIMEOUT_CONNECT)
        } catch {
            self.delegate?.didNotRespond(server: self)
        }
    }
    
    public func socket(_ sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        // Send the NICK message
        if sock == self.socket {
            if self.password.isEmpty {
                self.sendNickMessage()
            } else {
                self.sendPassMessage()
            }
        }
    }
    
    public func socket(_ sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        switch tag {
        case Tag.Pass:
            self.sendNickMessage()
        case Tag.Nick:
            self.sendUserMessage()
        default:
            break
        }
    }
    
    public func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {
        let string = String(bytes: data, encoding: self.encoding)
        print(string)
    }
    
    func sendPassMessage() {
        self.write(string: "\(Commands.PASS) \(self.password)", with: Tag.Pass)
    }
    
    func sendNickMessage() {
        self.write(string: "\(Commands.NICK) \(self.nickname)", with: Tag.Nick)
    }
    
    func sendUserMessage() {
        self.write(string: "\(Commands.USER) \(self.username) \(self.userBitmask) * :\(self.realname)", with: Tag.User)
    }
    
    public func disconnect() {
        write(string: Commands.QUIT)
        self.socket?.delegate = nil
        self.socket = nil
    }
    
    func write(string: String, with tag: Int) {
        var appendedString = "\(string)\n\r"
        let bytes = [UInt8](appendedString.utf8)
        self.socket?.write(Data(bytes: bytes), withTimeout: TIMEOUT_NONE, tag: tag)
    }
    
    func write(string: String) {
        var appendedString = "\(string)\n\r"
        let bytes = [UInt8](appendedString.utf8)
        self.socket?.write(Data(bytes: bytes), withTimeout: TIMEOUT_NONE, tag: Tag.None)
    }
    
}
