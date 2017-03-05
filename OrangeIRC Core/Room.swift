//
//  Room.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

open class Room : NSObject, NSCoding {
    
    // Should be set by the AppDelegate or ServerManager when the room is loaded or created
    open var server: Server!
    
    open var log = [LogEvent]()
    
    open var displayName: String {
        return ""
    }
    
    // To be implemented by subclasses
    open var canSendMessage: Bool {
        return false
    }
    
    // This is basically an "abstract class"
    override init() { }
    
    public required convenience init?(coder: NSCoder) {
        self.init()
    }
    
    open func encode(with aCoder: NSCoder) {

    }
    
}
