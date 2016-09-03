//
//  UserLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/3/16.
//
//

import Foundation

public class UserLogEvent : LogEvent {
    
    public var sender: String
    
    public init(sender: String) {
        self.sender = sender
    }
    
}
