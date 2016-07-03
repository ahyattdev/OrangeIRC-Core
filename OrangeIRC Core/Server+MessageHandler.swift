//
//  Server+MessageHandler.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/2/16.
//
//

import Foundation
import CocoaAsyncSocket

extension Server {
    
    func handle(message: Message) {
        print(message.message)
        
        switch message.command {
        case Command.Reply.WELCOME:
            self.delegate?.didRegister(server: self)
            self.isRegistered = true
        case Command.NOTICE:
            self.delegate?.recieved(notice: message.parameters!, server: self)
        case Command.PING:
            self.write(string: "\(Command.PONG) :\(message.parameters!)")
        default:
            print("Unimplemented command handle: \(message.command)")
        }
        socket?.readData(to: AsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
    }
}
