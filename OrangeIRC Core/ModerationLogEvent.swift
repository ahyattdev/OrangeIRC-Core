//
//  ModerationLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/30/17.
//
//

import Foundation

/// Parent class for log events relating to channel moderation
public class ModerationLogEvent : UserLogEvent {
    
    /// The user receiving the moderation event
    public var receiver: User
    
    internal init(sender: User, receiver: User, room: Room) {
        self.receiver = receiver
        super.init(sender: sender, room: room)
    }
    
}
