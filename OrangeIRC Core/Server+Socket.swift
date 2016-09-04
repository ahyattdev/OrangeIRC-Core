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
        reset()
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
    
    @objc(onSocket:didReadData:withTag:) public func onSocket(_ sock: AsyncSocket!, didRead data: Data!, withTag tag: Int) {
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
    
}
