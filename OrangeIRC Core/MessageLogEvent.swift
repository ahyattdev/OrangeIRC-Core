//
//  MessageLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 8/8/16.
//
//

import Foundation

open class MessageLogEvent : RoomLogEvent {
    
    open var contents: String
    open var sender: User
    
    init(contents: String, sender: User, room: Room) {
        self.contents = contents
        self.sender = sender
        super.init(room: room)
    }
    
    open override var attributedDescription: NSAttributedString {
        let nick = sender.coloredName(for: room)
        let str = NSMutableAttributedString()
        str.append(nick)
        str.append(NSAttributedString(string: ": \(contents)"))
        return str
    }
}
