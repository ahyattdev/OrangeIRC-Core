//
//  Notifications.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import Foundation

/// `NSNotification` constants used by `ServerManager. You can listen for them
/// in your own app.
public struct Notifications {
    
    private init() { }
    
    // Fix Me: Document what the objects of the notifications may be.
    
    /// Posted every time something notable related to any server in ServerManager.shared.servers changes.
    /// Examples: Servers created, servers deleted, servers disconnecting
    public static let serverDataChanged         = NSNotification.Name(rawValue: "ServerDataChanged")
    
    /// The state of the server changed
    public static let serverStateDidChange      = NSNotification.Name(rawValue: "ServerStateDidChange")
    /// Information for a user has changed
    public static let userInfoDidChange         = NSNotification.Name(rawValue: "UserInfoDidChange")
    
    /// A server was created
    public static let serverCreated             = NSNotification.Name(rawValue: "ServerCreated")
    /// A server was deleted
    public static let serverDeleted             = NSNotification.Name(rawValue: "ServerDeleted")
    
    /// The data for a room changed
    public static let roomDataChanged           = NSNotification.Name(rawValue: "RoomDataChanged")
    /// A room was deleted
    public static let roomDeleted               = NSNotification.Name(rawValue: "RoomDeleted")
    /// A room was created
    public static let roomCreated               = NSNotification.Name(rawValue: "RoomCreated")
    
    /// The state of a room changed
    public static let roomStateUpdated          = NSNotification.Name(rawValue: "RoomStateUpdated")
    
    /// A new log event is in the log for a room
    public static let newLogEventForRoom        = NSNotification.Name(rawValue: "NewLogEventForRoom")
    /// Topic changed for room
    public static let topicUpdatedForRoom       = NSNotification.Name(rawValue: "TopicUpdatedForRoom")
    /// User list updated for room
    public static let userListUpdatedForRoom    = NSNotification.Name(rawValue: "UserListUpdatedForRoom")
    
    /// Message Of The Day updated for server
    public static let motdUpdatedForServer      = NSNotification.Name(rawValue: "MOTDUpdatedForServer")
    
    /// Channel list updated for server
    public static let listUpdatedForServer      = NSNotification.Name(rawValue: "ListUpdatedForServer")
    /// Channel list fetch completed for server
    public static let listFinishedForServer     = NSNotification.Name(rawValue: "ListFinishedForServer")
        
}
