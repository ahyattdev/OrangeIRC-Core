//
//  RoomLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/11/17.
//
//

import Foundation

open class RoomLogEvent: LogEvent {
    
    open var room: Room
    
    internal init(room: Room) {
        self.room = room
        super.init()
    }
    
}
