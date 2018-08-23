//
//  RoomLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/11/17.
//
//

import Foundation

/// Parent class for log events relating to rooms
public class RoomLogEvent: LogEvent {
    
    /// The log event relating to the room
    public var room: Room
    
    internal init(room: Room) {
        self.room = room
        super.init()
    }
    
}
