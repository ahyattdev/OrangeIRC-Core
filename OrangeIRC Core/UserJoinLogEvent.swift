//
//  UserJoinLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/3/16.
//
//

import Foundation

/// When a user joins a channel
public class UserJoinLogEvent : UserLogEvent {
    
    /// Attributed description
    public override var attributedDescription: NSAttributedString {
        let str = NSMutableAttributedString()
        let nick = sender.coloredName(for: room)
        str.append(nick)
        str.append(NSAttributedString(string: " \(localized("JOINED"))"))
        str.addAttributes(LogEvent.italicAttributes, range: NSRange(location: 0, length: str.length))
        return str
    }
    
}
