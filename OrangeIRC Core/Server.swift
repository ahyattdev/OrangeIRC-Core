//
//  Server.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation

public class Server: NSObject, SocketDelegate {
    
    var delegate: ServerDelegate?
    
    var socket: Socket?
    
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
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosBackground).async(execute: {
            self.socket = Socket(host: self.host, port: self.port, delegate: self)
        })
    }
    
    public func disconnect() {
        write(string: Commands.QUIT)
    }
    
    func write(string: String) {
        var appendedString = "\(string)\n\r"
        let bytes = [UInt8](appendedString.utf8)
        self.socket?.write(bytes: Data(bytes: bytes))
    }
    
    public func couldNotConnect(socket: Socket) {
        self.delegate?.didNotRespond(server: self)
    }
    
    public func connectionSucceeded(socket: Socket) {
        
    }
    
    public func connectionFailed(socket: Socket) {
        self.delegate?.stoppedResponding(server: self)
    }
    
    public func connectionEnded(socket: Socket) {
        self.socket = nil
    }
    
    public func read(bytes: Data, on socket: Socket) {
        guard let string = String(bytes: bytes, encoding: self.encoding) else {
            print("String decoding error")
            return
        }
        print(string)
    }
    
    public func isConnected() -> Bool {
        if (self.socket != nil) {
            return (self.socket?.isOpen)!
        } else {
            return false
        }
    }
    
}
