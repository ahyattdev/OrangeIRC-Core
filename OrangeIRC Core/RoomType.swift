//
//  RoomType.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/18/16.
//
//

import Foundation

public enum RoomType : String {
    
    case Channel = "Channel"
    case PrivateMessage = "PrivateMessage"
    
    public func localizedName() -> String {
        switch self {
        case .Channel:
            return NSLocalizedString("CHANNEL", comment: "Channel")
        case .PrivateMessage:
            return NSLocalizedString("PRIVATE_MESSAGE", comment: "Private Message")
        }
    }
    
}
