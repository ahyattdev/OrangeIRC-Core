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

open class UserLogEvent : RoomLogEvent {
    
    open var sender: User
    
    public init(sender: User, room: Room) {
        self.sender = sender
        super.init(room: room)
    }
    
}
