//
//  Room.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

/// An IRC room. It is either a `Channel` or `PrivateMessage` at runtime.
open class Room : NSObject, NSCoding {
    
    // Should be set by the AppDelegate or ServerManager when the room is loaded or created
    /// The `Server` the room belongs to
    open var server: Server!
    
    /// The log of the room
    open var log = [LogEvent]()
    
    /// The display name of the room
    open var displayName: String {
        return ""
    }
    
    /// If the client is able to send messages to the room
    open var canSendMessage: Bool {
        return false
    }
    
    // This is basically an "abstract class"
    internal override init() { }
    
    /// Initialize using `NSCoding` APIs
    ///
    /// - Parameter coder: The coder
    public required convenience init?(coder: NSCoder) {
        self.init()
    }
    
    /// Encode using `NSCoding` APIs
    ///
    /// - Parameter aCoder: The coder
    open func encode(with aCoder: NSCoder) {

    }
    
    /// Send a message to the room
    ///
    /// - Parameter message: The message
    open func send(message: String) {
        fatalError("This should be overriden by subclasses")
    }
    
}
