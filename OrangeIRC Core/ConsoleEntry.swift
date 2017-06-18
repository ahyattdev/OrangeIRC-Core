//
//  ConsoleEntry.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/15/17.
//
//

import Foundation

public struct ConsoleEntry {
    
    public enum Sender {
        case Server
        case Client
    }
    
    public var text: String
    public var sender: Sender
    
    init(text: String, sender: Sender) {
        // Remove CRLF
        self.text = text.replacingOccurrences(of: "\r\n", with: "")
        self.sender = sender
    }
    
}
