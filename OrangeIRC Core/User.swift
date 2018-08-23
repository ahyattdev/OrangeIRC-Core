//
//  User.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

/// Named tuple of types for channel data
public typealias ChannelData = (name: String, mode: User.Mode, away: Bool)

/// An IRC user
open class User: NSObject, NSCoding {
    
    private struct Coding {
        
        private init() { }
        
        static let Nick = "Nick"
        
    }
    
    /// The user mode on the server
    ///
    /// - Operator: Operator
    /// - Voice: Voice
    /// - Invisible: Invisible
    /// - Deaf: Deaf
    /// - Zombie: Zombie
    /// - None: None
    public enum Mode : String {
        
        case Operator = "@"
        case Voice = "+"
        case Invisible = "<"
        case Deaf = "-"
        case Zombie = "!"
        case None = ""
        
        /// Valid user mode prefixes
        public static let validPrefixes = NSCharacterSet(charactersIn: "@+<-!")

    }
    
    /// User class, different than MODE
    ///
    /// - Normal: Normal user
    /// - Operator: Server operator
    public enum Class {
        
        case Normal
        case Operator
        
    }
    
    /// The channels the user is on
    internal(set) public var channels = [ChannelData]()
    
    /// Nickname
    internal(set) public var nick: String
    
    /// User online status
    internal(set) public var isOnline = true
    
    // Begin WHOIS data
    /// Username
    internal(set) public var username: String?
    /// Hostname
    internal(set) public var host: String?
    /// User IP
    internal(set) public var ip: String?
    /// Server name
    internal(set) public var servername: String?
    /// Real name
    internal(set) public var realname: String?
    /// Online time
    internal(set) public var onlineTime: Date?
    /// Idle time
    internal(set) public var idleTime: Date?
    /// User channel list
    internal(set) public var channelList: [String]?
    /// User class
    internal(set) public var `class`: Class?
    /// User away message
    internal(set) public var awayMessage: String?
    /// User away status
    internal(set) public var away: Bool?
    
    internal init(_ nick: String) {
        self.nick = nick
    }
    
    /// Initialize using `NSCoding` APIs
    ///
    /// - Parameter coder: The coder
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let nick = aDecoder.decodeObject(forKey: Coding.Nick) as? String else {
            return nil
        }
        
        self.init(nick)
    }
    
    /// Encode using `NSCoding` APIs
    ///
    /// - Parameter aCoder: The coder
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(nick, forKey: Coding.Nick)
    }
    
    /// Gets the MODE of a user on a `Channel`
    ///
    /// - Parameter channel: Channel
    /// - Returns: User `Mode`
    open func getMode(for channel: String) -> Mode? {
        // Search through the list of channels this user is on to get the one we want and return it
        for channelNode in channels {
            if channelNode.name == channel {
                return channelNode.mode
            }
        }
        // The user isn't on the requested channel
        return nil
    }
    
    internal func set(mode: Mode, for channel: String) {
        // Search through the list of channels this user is on to get the one we want and set it
        for var channelNode in channels {
            if channelNode.name == channel {
                channelNode.mode = mode
                return
            }
        }
        print("This user is not on the specified channel")
    }
    
    /// Gets the away status of a user for a `Channel`
    ///
    /// - Parameter channel: Channel
    /// - Returns: Away status
    open func getAway(for channel: String) -> Bool? {
        // FIXME: Is away per channel?
        // Search through the list of channels this user is on to get the one we want and return it
        for channelNode in channels {
            if channelNode.name == channel {
                return channelNode.away
            }
        }
        // The user isn't on the requested channel
        return nil
    }
    
    /// Sets the away status of a user on a channel
    ///
    /// - Parameters:
    ///   - away: Away status
    ///   - channel: Channel
    internal func set(away: Bool, for channel: String) {
        // Search through the list of channels this user is on to get the one we want and set it
        for var channelNode in channels {
            if channelNode.name == channel {
                channelNode.away = away
                return
            }
        }
        print("This user is not on the specified channel")
    }
    
    /// Gets if a user is on a `Channel`
    ///
    /// - Parameter channel: Channel
    /// - Returns: If the user is on the channel
    open func isOn(channel: String) -> Bool {
        for channelNode in channels {
            if channelNode.name == channel {
                return true
            }
        }
        return false
    }
    
    internal func removeFrom(channel: String) {
        for i in 0 ..< channels.count {
            if channels[i].name == channel {
                channels.remove(at: i)
                break
            }
        }
    }
    
    
    #if os(iOS) || os(tvOS)
    
    /// The color of an IRC user, on a per room basis.
    ///
    /// - Parameter room: The room
    /// - Returns: The color for the user in the room
    open func color(room: Room) -> UIColor {
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
    
    #else
    
    /// The color of an IRC user, on a per room basis.
    ///
    /// - Parameter room: The room
    /// - Returns: The color for the user in the room
    open func color(room: Room) -> NSColor {
        if let channel = room as? Channel {
            guard let mode = getMode(for: channel.name) else {
                // The user is not in the room
                // Not really an error, this is just how users who leave are rendered
                return NSColor.lightGray
            }
            
            var color = NSColor.black
            switch mode {
            case .Operator:
                color = NSColor.red
            case .Voice:
                color = NSColor.blue
            case .Invisible:
                color = NSColor.gray
            case .Deaf:
                color = NSColor.lightGray
            case .Zombie:
                color = NSColor.gray
            case .None:
                // Default text color
                break
            }
            
            if !channel.isJoined {
                color = NSColor.lightGray
            }
            
            if room.server!.userCache.me == self {
                color = NSColor.orange
            }
            
            return color
        } else if room is PrivateMessage {
            return NSColor.black
        } else {
            // So we know that there was an issue
            return NSColor.purple
        }
    }

    #endif
    
    /// The colored name for the user
    ///
    /// - Parameter room: The room to determine the color for
    /// - Returns: The color the the user
    open func coloredName(for room: Room) -> NSAttributedString {
        // The properly colored attributes
        let attributes = [NSAttributedStringKey.foregroundColor : color(room: room)]
        return NSAttributedString(string: nick, attributes: attributes)
    }
    
    /// Compares two `User` instances
    open static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.nick == rhs.nick
    }
    
}
