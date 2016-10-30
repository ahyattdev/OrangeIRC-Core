//
//  MessageLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 8/8/16.
//
//

import Foundation

public class MessageLogEvent : LogEvent, CustomDebugStringConvertible {
    
    public var contents: String
    public var sender: User
    
    public init(contents: String, sender: User) {
        self.contents = contents
        self.sender = sender
    }
    
    public var debugDescription: String {
        return "MessageLogEvent(contents: \(contents), sender: \(sender.name)"
    }
    
}
