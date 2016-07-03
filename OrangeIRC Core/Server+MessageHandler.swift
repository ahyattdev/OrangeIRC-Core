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
        case Command.NOTICE:
            self.delegate?.recieved(notice: message.parameters, server: self)
        default:
            print("Unimplemented command handle: \(message.command)")
        }
        socket?.readData(to: AsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
    }
}
