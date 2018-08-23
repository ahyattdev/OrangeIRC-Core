//
//  UserQuitLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/4/16.
//
//

import Foundation

/// When a user quits from the server
public class UserQuitLogEvent : UserLogEvent {
    
    /// Attributed description
    public override var attributedDescription: NSAttributedString {
        let str = NSMutableAttributedString()
        let nick = sender.coloredName(for: room)
        str.append(nick)
        str.append(NSAttributedString(string: " \(localized("QUIT"))"))
        str.addAttributes(LogEvent.italicAttributes, range: NSRange(location: 0, length: str.length))
        return str
    }
    
}
