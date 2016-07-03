//
//  Commands.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/29/16.
//
//

import Foundation

public struct Command {
    
    static let JOIN = "JOIN"
    static let NICK = "NICK"
    static let PART = "PART"
    static let PASS = "PASS"
    static let PING = "PING"
    static let PONG = "PONG"
    static let QUIT = "QUIT"
    static let USER = "USER"
    
    static let NOTICE = "NOTICE"
    
    struct Reply {
        
        static let WELCOME = "001"
        static let YOURHOST = "002"
        static let CREATED = "003"
        static let MYINFO = "004"
    }
    
}
