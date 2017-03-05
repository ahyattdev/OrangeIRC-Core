//
//  UserLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/3/16.
//
//

import Foundation

open class UserLogEvent : LogEvent {
    
    open var sender: User
    
    public init(sender: User) {
        self.sender = sender
    }
    
}
