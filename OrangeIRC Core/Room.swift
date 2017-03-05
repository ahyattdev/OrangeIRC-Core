//
//  Room.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

public class Room : NSObject, NSCoding {
    
    // Should be set by the AppDelegate or ServerManager when the room is loaded or created
    public var server: Server!
    
    public var log = [LogEvent]()
    
    // This is basically an "abstract class"
    override init() { }
    
    public required convenience init?(coder: NSCoder) {
        self.init()
    }
    
    public func encode(with aCoder: NSCoder) {

    }
    
}
