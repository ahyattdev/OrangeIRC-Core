//
//  Notifications.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import Foundation

public struct Notifications {
    
    private init() { }
    
    // Posted every time something notable related to any server in ServerManager.shared.servers changes,
    // Examples: Servers created, servers deleted, servers disconnecting
    // Never has an object
    public static let ServerDataChanged         = NSNotification.Name(rawValue: "ServerDataChanged")
    
    public static let ServerStateDidChange      = NSNotification.Name(rawValue: "ServerStateDidChange")
    public static let UserInfoDidChange         = NSNotification.Name(rawValue: "UserInfoDidChange")
    
    public static let ServerCreated             = NSNotification.Name(rawValue: "ServerCreated")
    public static let ServerDeleted             = NSNotification.Name(rawValue: "ServerDeleted")
    
    public static let RoomDataChanged           = NSNotification.Name(rawValue: "RoomDataChanged")
    public static let RoomDeleted               = NSNotification.Name(rawValue: "RoomDeleted")
    public static let RoomCreated               = NSNotification.Name(rawValue: "RoomCreated")
    
    public static let RoomStateUpdated          = NSNotification.Name(rawValue: "RoomStateUpdated")
    
    public static let NewLogEventForRoom        = NSNotification.Name(rawValue: "NewLogEventForRoom")
    public static let TopicUpdatedForRoom       = NSNotification.Name(rawValue: "TopicUpdatedForRoom")
    public static let UserListUpdatedForRoom    = NSNotification.Name(rawValue: "UserListUpdatedForRoom")
    
    public static let MOTDUpdatedForServer      = NSNotification.Name(rawValue: "MOTDUpdatedForServer")
    
    public static let ListUpdatedForServer      = NSNotification.Name(rawValue: "ListUpdatedForServer")
    public static let ListFinishedForServer     = NSNotification.Name(rawValue: "ListFinishedForServer")
        
}
