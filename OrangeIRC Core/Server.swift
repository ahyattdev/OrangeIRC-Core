//
//  Server.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation
import CocoaAsyncSocket

let TIMEOUT = TimeInterval(30)

public class Server: AnyObject, GCDAsyncSocketDelegate {
    
    var delegate: ServerDelegate?
    
    var socket: GCDAsyncSocket?
    
    var host: String
    
    var port: Int
    
    var nickname: String
    var username: String
    var realname: String
    
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
    
    public func connect() {
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    public func disconnect() {
        write(string: Commands.QUIT)
        self.socket?.delegate = nil
        self.socket = nil
    }
    
    func write(string: String) {
        var appendedString = "\(string)\n\r"
        let bytes = [UInt8](appendedString.utf8)
        self .socket?.write(Data(bytes: bytes), withTimeout: TIMEOUT, tag: 0)
    }
    
    public func couldNotConnect(socket: Socket) {
        self.delegate?.didNotRespond(server: self)
    }
    
    public func connectionSucceeded(socket: Socket) {

    }
    
    public func canWriteBytes(socket: Socket) {
        // Send the NICK message
        if socket == self.socket {
            self.write(string: "\(Commands.NICK) \(self.nickname)")
        }
    }
    
    public func connectionFailed(socket: Socket) {
        self.delegate?.stoppedResponding(server: self)
    }
    
    public func connectionEnded(socket: Socket) {
        self.socket = nil
    }
    
    public func read(bytes: Data, on socket: Socket) {
        let string = String(bytes: bytes, encoding: self.encoding)
        print(string)
    }
    
//    public func isConnected() -> Bool {
//        if (self.socket != nil) {
//            return (self.socket?.isOpen)!
//        } else {
//            return false
//        }
//    }
    
}
