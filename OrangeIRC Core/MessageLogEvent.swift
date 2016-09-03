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
    
    public init(contents: String, sender: User) {
        self.contents = contents
        self.sender = sender
    }
    
}
