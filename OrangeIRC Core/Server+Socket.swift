//
//  Server+Socket.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/4/16.
//
//

import Foundation
import CocoaAsyncSocket

extension Server {
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        delegate?.connectedSucessfully(server: self)
        socket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
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
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        // We need to wait after QUIT is sent, as things are sent asyncronously
        reset()
    }
    
    @objc(socket:didReadData:withTag:) public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
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
            socket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
        }
    }
    
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
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
    
}
