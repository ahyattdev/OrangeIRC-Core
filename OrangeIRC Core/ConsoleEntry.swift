//
//  ConsoleEntry.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/15/17.
//
//

import Foundation

/// An entry in the server consolelog
public struct ConsoleEntry {
    
    /// The sender of the message
    public enum Sender {
        /// Them
        case Server
        /// Us
        case Client
    }
    
    /// The raw text of the log message
    public var text: String
    /// The sender of the log message
    public var sender: Sender
    
    internal init(text: String, sender: Sender) {
        // Remove CRLF
        self.text = text.replacingOccurrences(of: "\r\n", with: "")
        self.sender = sender
    }
    
}
