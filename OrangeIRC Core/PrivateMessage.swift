//
//  PrivateMessage.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/5/17.
//
//

import Foundation

open class PrivateMessage : Room {
    
    fileprivate struct Coding {
        
        private init() { }
        
        static let OtherUser = "OtherUser"
        
    }
    
    // The user that this private message session is with
    open let otherUser: User
    
    open override var displayName: String {
        return otherUser.nick
    }
    
    open override var canSendMessage: Bool {
        return otherUser.isOnline && server.isRegistered
    }
    init(_ otherUser: User) {
        self.otherUser = otherUser
        super.init()
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let otherUser = coder.decodeObject(forKey: Coding.OtherUser) as? User else {
            return nil
        }
        self.init(otherUser)
    }
    
    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(otherUser, forKey: Coding.OtherUser)
    }
    
    open override func send(message: String) {
        server.write(string: "\(Command.PRIVMSG) \(otherUser.nick) :\(message)")
        let logEvent = MessageLogEvent(contents: message, sender: server.userCache.me, room: self)
        log.append(logEvent)
        server.delegate?.received(logEvent: logEvent, for: self)
    }
    
}
