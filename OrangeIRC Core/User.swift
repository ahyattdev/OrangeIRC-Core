//
//  User.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

public class User {
    
    public var name: String
    
    public var isSelf = false
    
    public init(name: String) {
        self.name = name
    }
    
}
