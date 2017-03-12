//
//  RoomLogEvent.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/11/17.
//
//

import Foundation

open class RoomLogEvent: LogEvent {
    
    let room: Room
    
    private init(room: Room) {
        self.room = room
    }
    
}
