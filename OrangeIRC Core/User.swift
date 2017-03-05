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

public class User: NSObject, NSCoding {
    
    private struct Coding {
        
        private init() { }
        
        static let Nick = "Nick"
        
    }
    
    public enum Mode : String {
        
        public static let PREFIX_CHARACTER_SET = NSCharacterSet(charactersIn: "@+<-!")
        
        case Operator = "@"
        case Voice = "+"
        case Invisible = "<"
        case Deaf = "-"
        case Zombie = "!"
        case None = ""
        
    }
    
    public enum Class {
        
        case Normal
        case Operator
        
    }
    
    public typealias ChannelData = (name: String, mode: Mode, away: Bool)
    
    public var channels = [ChannelData]()
    
    // Nickname
    public var nick: String
    
    public var isOnline = true
    
    // Begin WHOIS data
    public var username: String?
    public var host: String?
    public var ip: String?
    public var servername: String?
    public var realname: String?
    public var onlineTime: Date?
    public var idleTime: Date?
    public var channelList: [String]?
    public var `class`: Class?
    public var awayMessage: String?
    public var away: Bool?
    
    public init(_ nick: String) {
        self.nick = nick
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let nick = aDecoder.decodeObject(forKey: Coding.Nick) as? String else {
            return nil
        }
        
        self.init(nick)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(nick, forKey: Coding.Nick)
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
        if let channel = room as? Channel {
            guard let mode = getMode(for: channel.name) else {
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
            
            if !channel.isJoined {
                color = UIColor.lightGray
            }
            
            if room.server!.userCache.me == self {
                color = UIColor.orange
            }
            
            return color
        } else if room is PrivateMessage {
            return UIColor.black
        } else {
            // So we know that there was an issue
            return UIColor.purple
        }
    }
    
    public func coloredName(for room: Room) -> NSAttributedString {
        // The properly colored attributes
        let attributes = [NSForegroundColorAttributeName : color(room: room)]
        return NSAttributedString(string: nick, attributes: attributes)
    }
    
#endif
    
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.nick == rhs.nick
    }
    
}
