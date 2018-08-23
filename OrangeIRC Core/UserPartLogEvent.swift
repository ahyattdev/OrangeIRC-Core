//
//  UserPartLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/3/16.
//
//

import Foundation

/// When a user leaves a channel
public class UserPartLogEvent : UserLogEvent {
    
    /// Attributed description
    public override var attributedDescription: NSAttributedString {
        let str = NSMutableAttributedString()
        let nick = sender.coloredName(for: room)
        str.append(nick)
        str.append(NSAttributedString(string: " \(localized("LEFT"))"))
        str.addAttributes(LogEvent.italicAttributes, range: NSRange(location: 0, length: str.length))
        return str
    }
    
}
