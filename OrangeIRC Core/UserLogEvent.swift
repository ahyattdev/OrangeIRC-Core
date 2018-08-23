//
//  UserLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/3/16.
//
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import Foundation
#endif

/// Parent class for log events relating to users
public class UserLogEvent : RoomLogEvent {
    
    /// The user that did the action
    public var sender: User
    
    internal init(sender: User, room: Room) {
        self.sender = sender
        super.init(room: room)
    }
    
}
