//
//  UserNickChangeLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/25/17.
//
//

import Foundation

class UserNickChangeLogEvent : UserLogEvent {
    
    let oldNick: String
    let newNick: String
    
    init(sender: User, room: Room, oldNick: String, newNick: String) {
        self.oldNick = oldNick
        self.newNick = newNick
        super.init(sender: sender, room: room)
    }
    
}
