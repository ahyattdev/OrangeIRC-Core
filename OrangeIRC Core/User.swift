//
//  User.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#endif

public class User {
    
    public enum Mode : String {
        
        public static let PREFIX_CHARACTER_SET = NSCharacterSet(charactersIn: "@+<-!")
        
        case Operator = "@"
        case Voice = "+"
        case Invisible = "<"
        case Deaf = "-"
        case Zombie = "!"
        case None = ""
        
    }
    
    public typealias ChannelData = (name: String, mode: Mode, away: Bool)
    
    public var channels = [ChannelData]()
    
    public var name: String
    
    public var isSelf = false
    
    public init(name: String) {
        self.name = name
    }
    
    public func getMode(for channel: String) -> Mode? {
        // Search through the list of channels this user is on to get the one we want and return it
        for channelNode in channels {
            if channelNode.name == channel {
                return channelNode.mode
            }
        }
        // The user isn't on the requested channel
        return nil
    }
    
    public func set(mode: Mode, for channel: String) {
        // Search through the list of channels this user is on to get the one we want and set it
        for var channelNode in channels {
            if channelNode.name == channel {
                channelNode.mode = mode
                return
            }
        }
        print("This user is not on the specified channel")
    }
    
    public func getAway(for channel: String) -> Bool? {
        // Search through the list of channels this user is on to get the one we want and return it
        for channelNode in channels {
            if channelNode.name == channel {
                return channelNode.away
            }
        }
        // The user isn't on the requested channel
        return nil
    }
    
    public func set(away: Bool, for channel: String) {
        // Search through the list of channels this user is on to get the one we want and set it
        for var channelNode in channels {
            if channelNode.name == channel {
                channelNode.away = away
                return
            }
        }
        print("This user is not on the specified channel")
    }
    
    public func isOn(channel: String) -> Bool {
        for channelNode in channels {
            if channelNode.name == channel {
                return true
            }
        }
        return false
    }
    
    public func removeFrom(channel: String) {
        for i in 0 ..< channels.count {
            if channels[i].name == channel {
                channels.remove(at: i)
                break
            }
        }
    }
    
    
#if os(iOS) || os(tvOS)
    
    public func color(room: Room) -> UIColor {
        guard let mode = getMode(for: room.name) else {
            // The user is not in the room
            // Not really an error, this is just how users who leave are rendered
            return UIColor.lightGray
        }
        
        var color = UIColor.black
        switch mode {
        case .Operator:
            color = UIColor.red
        case .Voice:
            color = UIColor.blue
        case .Invisible:
            color = UIColor.gray
        case .Deaf:
            color = UIColor.lightGray
        case .Zombie:
            color = UIColor.gray
        case .None:
            // Default text color
            break
        }
        
        if !room.isJoined {
            color = UIColor.lightGray
        }
        
        if isSelf {
            color = UIColor.orange
        }
        
        return color
    }
    
    public func coloredName(for room: Room) -> NSAttributedString {
        // The properly colored attributes
        let attributes = [NSForegroundColorAttributeName : color(room: room)]
        return NSAttributedString(string: name, attributes: attributes)
    }
    
#endif
    
}
