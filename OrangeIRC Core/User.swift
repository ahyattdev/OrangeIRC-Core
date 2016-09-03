//
//  User.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

public class User {
    
    public enum Mode : String {
        
        case Operator = "@"
        case Voice = "+"
        case Invisible = "<"
        case Deaf = "-"
        case Zombie = "!"
        case None = ""
        
    }
    
    public var mode: Mode
    
    public var name: String
    
    public var isSelf = false
    
    public init(name: String, mode: Mode) {
        self.name = name
        self.mode = mode
    }
    
}
