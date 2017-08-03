//
//  Channel.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/5/17.
//
//

import Foundation

open class Channel : Room {
    
    // https://www.alien.net.au/irc/chantypes.html
    open static let CHANNEL_PREFIXES = NSCharacterSet(charactersIn: "#&!+.~")
    
    fileprivate struct Coding {
        
        // To prevent this struct from being initialized
        private init() { }
        
        static let Name = "Name"
        static let Key = "Key"
        static let AutoJoin = "AutoJoin"
        
    }
    
    // Preserved variables
    open var name: String
    open var key: String?
    open var autoJoin = false // Only does something if this is a channel
    
    open var users = [User]()
    
    open var topic: String?
    open var url: URL?
    
    open var hasTopic = false
    
    // If this is a private message room, this will be if both us and the recipient are on the server
    open var isJoined = false
    
    open override var canSendMessage: Bool {
        return isJoined && server.isRegistered
    }
    
    // Set for the connect and join button
    open var joinOnConnect = false
    
    // Don't display the users list while it is still being populated
    open var hasCompleteUsersList = false
    
    open override var displayName: String {
        return name
    }
    
    public init(_ name: String) {
        self.name = name
        super.init()
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: Coding.Name) as? String else {
            return nil
        }
        
        self.init(name)
        
        key = coder.decodeObject(forKey: Coding.Key) as? String
        autoJoin = coder.decodeBool(forKey: Coding.AutoJoin)
    }
    
    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Coding.Name)
        aCoder.encode(key, forKey: Coding.Key)
        aCoder.encode(autoJoin, forKey: Coding.AutoJoin)
    }
    
    func contains(user: User) -> Bool {
        for testUser in users {
            if testUser === user {
                return true
            }
        }
        return false
    }
    
    func sortUsers() {
        users.sort(by: { (a: User, b: User) -> Bool in
            return a.nick < b.nick
        })
    }
    
    override open func send(message: String) {
        // Splits the message up into 512 byte chunks
        var message = message
        var messageParts = [String]()
        let commandPrefix = "\(Command.PRIVMSG) \(name) :"
        let MAX = 510 - commandPrefix.utf8.count
        
        while !message.isEmpty {
            if message.utf8.count > MAX {
                let range = message.utf8.startIndex ..< message.utf8.index(message.utf8.startIndex, offsetBy: MAX)
                let part = message.utf8[range]
                messageParts.append(String(describing: part))
                
                // For some reason, we cant remove range in the UTF8View
                for _ in 0 ..< MAX {
                    _ = message.utf8.popFirst()
                }
            } else {
                let range = message.utf8.startIndex ..< message.utf8.endIndex
                let part = String(message.utf8[range])
                messageParts.append(part!)
                message = ""
            }
            
            for part in messageParts {
                server!.write(string: "\(commandPrefix)\(part)")
                
                let logEvent = MessageLogEvent(contents: part, sender: server!.userCache.me, room: self)
                log.append(logEvent)
                server!.delegate?.received(logEvent: logEvent, for: self)
            }
        }
    }
    
}
