//
//  UserNickChangeLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/25/17.
//
//

import Foundation

/// When a user changes their nickname
public class UserNickChangeLogEvent : UserLogEvent {
    
    /// Old nickname
    public let oldNick: String
    
    /// New nickname
    public let newNick: String
    
    /// Attributed description
    public override var attributedDescription: NSAttributedString {
        let str = NSMutableAttributedString()
        str.append(NSAttributedString(string: "\(oldNick) \(localized("CHANGED_NICKNAME_TO")) \(newNick)"))
        str.addAttributes(LogEvent.italicAttributes, range: NSRange(location: 0, length: str.length))
        return str
    }
    
    internal init(sender: User, room: Room, oldNick: String, newNick: String) {
        self.oldNick = oldNick
        self.newNick = newNick
        super.init(sender: sender, room: room)
    }
    
}
