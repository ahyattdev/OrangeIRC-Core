//
//  MessageLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 8/8/16.
//
//

import Foundation

public class MessageLogEvent : LogEvent {
    
    public var contents: String
    public var sender: User
    public var replyTo: User?
    
    init(_ contents: String, sender: User, userCache: UserCache) {
        self.contents = contents
        self.sender = sender
        
        // See if this message is a reply
        if let colonSpace = contents.range(of: ": "), let space = contents.range(of: " ")?.lowerBound {
            if colonSpace.lowerBound < space {
                // There is a nickname at the front of this message
                let nick = contents[contents.startIndex ..< colonSpace.lowerBound]
                if !nick.isEmpty {
                    replyTo = userCache.getOrCreateUser(nickname: nick)
                    self.contents = contents[colonSpace.upperBound ..< contents.endIndex]
                }
            }
        }
    }
    
}
