//
//  ModerationLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/30/17.
//
//

import Foundation

open class ModerationLogEvent : UserLogEvent {
    
    open var receiver: User
    
    public init(sender: User, receiver: User, room: Room) {
        self.receiver = receiver
        super.init(sender: sender, room: room)
    }
    
}
