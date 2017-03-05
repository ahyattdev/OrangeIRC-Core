//
//  PrivateMessage.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/5/17.
//
//

import Foundation

public class PrivateMessage : Room {
    
    fileprivate struct Coding {
        
        private init() { }
        
        static let OtherUser = "OtherUser"
        
    }
    
    // The user that this private message session is with
    public let otherUser: User
    
    init(_ otherUser: User) {
        self.otherUser = otherUser
        super.init()
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let otherUser = coder.decodeObject(forKey: Coding.OtherUser) as? User else {
            return nil
        }
        self.init(otherUser)
    }
    
    public override func encode(with aCoder: NSCoder) {
        aCoder.encode(otherUser, forKey: Coding.OtherUser)
    }
    
}
