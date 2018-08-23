//
//  PrivateMessage.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/5/17.
//
//

import Foundation

/// A private message session with another user
open class PrivateMessage : Room {
    
    fileprivate struct Coding {
        
        private init() { }
        
        static let OtherUser = "OtherUser"
        
    }
    
    /// The user that this private message session is with
    open let otherUser: User
    
    /// The display name of the private message room
    open override var displayName: String {
        return otherUser.nick
    }
    
    /// If the client is able to message the other user
    open override var canSendMessage: Bool {
        return otherUser.isOnline && server.isRegistered
    }
    
    internal init(_ otherUser: User) {
        self.otherUser = otherUser
        super.init()
    }
    
    /// Initialize using `NSCoding` APIs
    ///
    /// - Parameter coder: The coder
    public required convenience init?(coder: NSCoder) {
        guard let otherUser = coder.decodeObject(forKey: Coding.OtherUser) as? User else {
            return nil
        }
        self.init(otherUser)
    }
    
    /// Encode using `NSCoding` APIs
    ///
    /// - Parameter aCoder: The coder
    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(otherUser, forKey: Coding.OtherUser)
    }
    
    /// Send a message to the private message user
    ///
    /// - Parameter message: The message
    open override func send(message: String) {
        // FIXME: Message size limit, chunk it?
        server.write(string: "\(Command.PRIVMSG) \(otherUser.nick) :\(message)")
        let logEvent = MessageLogEvent(contents: message, sender: server.userCache.me, room: self)
        log.append(logEvent)
        server.delegate?.received(logEvent: logEvent, for: self)
    }
    
}
