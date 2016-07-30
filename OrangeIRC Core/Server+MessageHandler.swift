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
        switch message.command {
        case Command.Reply.WELCOME:
            self.isConnectingOrRegistering = false
            self.delegate?.didRegister(server: self)
            self.isRegistered = true
            
        case Command.Reply.YOURHOST:
            // Not useful
            break
            
        case Command.Reply.CREATED:
            // Not useful
            break
            
        case Command.JOIN:
            // A channel was sucessfully joined
            let channelName = message.target[0]
            var room: Room?
            if !alreadyExists(room: channelName) {
                // Create a new room with log
                let channel = Room(name: channelName, type: .Channel, server: self)
                self.rooms.append(channel)
                room = channel
            } else {
                room = roomFrom(name: channelName)
            }
            // Send a channel join message
            self.delegate?.joined(room: room!)
            
        case Command.NOTICE:
            self.delegate?.recieved(notice: message.parameters!, server: self)
            
        case Command.PING:
            self.write(string: "\(Command.PONG) :\(message.parameters!)")
            
        case Command.Reply.MOTD:
            self.motd = "\(self.motd)\(message.parameters!)\n"
            
        case Command.Reply.ENDOFMOTD:
            self.finishedReadingMOTD = true
            self.delegate?.finishedReadingMOTD(server: self)
            
        default:
            print(message.message)
            print("Unimplemented command handle: \(message.command)")
        }
        
        socket?.readData(to: AsyncSocket.crlfData(), withTimeout: TIMEOUT_NONE, tag: Tag.Normal)
    }
    
}
