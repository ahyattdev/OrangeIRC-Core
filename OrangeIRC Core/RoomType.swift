//
//  RoomType.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/18/16.
//
//

import Foundation

/// The type of a `Room`
///
/// - Channel: IRC channel
/// - PrivateMessage: Private message session
public enum RoomType : String {
    
    case Channel = "Channel"
    case PrivateMessage = "PrivateMessage"
    
    /// Gets a localized name for the room type
    ///
    /// - Returns: Localized room type
    public func localizedName() -> String {
        switch self {
        case .Channel:
            return localized("CHANNEL")
        case .PrivateMessage:
            return localized("PRIVATE_MESSAGE")
        }
    }
    
}
