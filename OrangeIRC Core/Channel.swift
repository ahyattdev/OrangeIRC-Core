// This file of part of the Swift IRC client framework OrangeIRC Core.
//
// Copyright © 2016 Andrew Hyatt
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

/// An IRC channel
open class Channel : Room {
    
    /// Valid IRC channel prefixes
    ///
    /// - Note: The source is https://www.alien.net.au/irc/chantypes.html
    public static let channelPrefixes = NSCharacterSet(charactersIn: "#&!+.~")
    
    fileprivate struct Coding {
        
        // To prevent this struct from being initialized
        private init() { }
        
        static let Name = "Name"
        static let Key = "Key"
        static let AutoJoin = "AutoJoin"
        
    }
    
    // Preserved variables
    
    /// The channel name
    ///
    /// *Preserved on save*
    open var name: String
    
    /// The channel key
    ///
    /// *Preserved on save*
    open var key: String?
    
    /// Automatically join the room.
    ///
    /// *Preserved on save*
    open var autoJoin = false
    
    // End preserved variables
    
    /// The users in this channel
    internal(set) open var users = [User]()
    
    /// The channel topic
    internal(set) open var topic: String?
    
    /// Channel URL
    internal(set) open var url: URL?
    
    /// If the channel has a topic
    internal(set) open var hasTopic = false
    
    // If this is a private message room, this will be if both us and the recipient are on the server
    /// Channel join status
    internal(set) open var isJoined = false
    
    /// Is the client allowed to send a message on the channel
    open override var canSendMessage: Bool {
        // FIX ME: Check for permissions such as mute
        return isJoined && server.isRegistered
    }
    
    // Set for the connect and join button
    /// Join this channel when the server connects
    open var joinOnConnect = false
    
    // Don't display the users list while it is still being populated
    /// Is the users list complete yet
    internal(set) open var hasCompleteUsersList = false
    
    /// The display name of the channel
    open override var displayName: String {
        return name
    }
    
    /// Create a channel
    ///
    /// - Parameter name: Channel name
    internal init(_ name: String) {
        self.name = name
        super.init()
    }
    
    /// Initialize using `NSCoding` APIs
    ///
    /// - Parameter coder: Coder
    public required convenience init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: Coding.Name) as? String else {
            return nil
        }
        
        self.init(name)
        
        key = coder.decodeObject(forKey: Coding.Key) as? String
        autoJoin = coder.decodeBool(forKey: Coding.AutoJoin)
    }
    
    /// Encodes using `NSCoding` APIs
    ///
    /// - Parameter aCoder: The coder
    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Coding.Name)
        aCoder.encode(key, forKey: Coding.Key)
        aCoder.encode(autoJoin, forKey: Coding.AutoJoin)
    }
    
    /// Checks if the channel contains a user
    ///
    /// - Parameter user: The user to check for
    /// - Returns: If the user is in the channel
    func contains(user: User) -> Bool {
        for testUser in users {
            if testUser === user {
                return true
            }
        }
        return false
    }
    
    /// Sort the channel user list
    func sortUsers() {
        users.sort(by: { (a: User, b: User) -> Bool in
            return a.nick < b.nick
        })
    }
    
    /// Send a message on the Channel
    ///
    /// - Parameter message: Message to send
    override open func send(message: String) {
        // Splits the message up into 512 byte chunks
        var message = message
        var messageParts = [String]()
        let commandPrefix = "\(Command.PRIVMSG) \(name) :"
        let MAX = 510 - commandPrefix.utf8.count
        
        while !message.isEmpty {
            if message.utf8.count > MAX {
                // Split this part of the message up
                let range = message.utf8.startIndex ..< message.utf8.index(message.utf8.startIndex, offsetBy: MAX)
                let part = message.utf8[range]
                messageParts.append(String(describing: part))
                
                message = String(message.utf8.dropFirst(MAX))!
            } else {
                // It is OK to send the message as it is
                messageParts.append(message)
                message = ""
            }
        }
        
        for part in messageParts {
            server!.write(string: "\(commandPrefix)\(part)")
            
            let logEvent = MessageLogEvent(contents: part, sender: server!.userCache.me, room: self)
            log.append(logEvent)
            server!.delegate?.received(logEvent: logEvent, for: self)
        }
    }
    
}
