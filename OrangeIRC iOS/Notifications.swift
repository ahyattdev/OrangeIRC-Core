//
//  Notifications.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import Foundation

struct Notifications {
    
    private init() { }
    
    static let ServerStateDidChange = NSNotification.Name(rawValue: "ServerStateDidChange")
    static let RoomDataDidChange = NSNotification.Name(rawValue: "RoomDataDidChange")
    static let DisplayedRoomDidChange = NSNotification.Name(rawValue: "DisplayedRoomDidChange")
    static let RoomLogDidChange = NSNotification.Name(rawValue: "RoomLogDidChange")
    
}
