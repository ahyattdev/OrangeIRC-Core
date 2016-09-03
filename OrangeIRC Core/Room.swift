//
//  Room.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

public class Room : NSObject, NSCoding {
    
    struct Coding {
        
        static let Name = "Name"
        // We can't call it Type, because that would be a keyword
        static let RoomType = "Type"
        
    }
    
    public var server: Server?
    
    public var log = [LogEvent]()
    
    public var users = [User]()
    
    public var name: String
    
    public var topic: String?
    
    public var hasTopic = true
    
    public var isJoined = false
    
    public var type: RoomType
    
    // Don't display the users list while it is still being populated
    public var hasCompleteUsersList = false
    
    public init(name: String, type: RoomType) {
        self.name = name
        self.type = type
        super.init()
    }
    
    public convenience init(name: String, type: RoomType, server: Server) {
        self.init(name: name, type: type)
        self.server = server
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: Coding.Name) as? String,
            let rawType = coder.decodeObject(forKey: Coding.RoomType) as? String else {
            return nil
        }
        
        guard let type = RoomType(rawValue: rawType) else {
            return nil
        }
        
        self.init(name: name, type: type)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: Coding.Name)
        aCoder.encode(self.type.rawValue, forKey: Coding.RoomType)
    }
    
    func addUser(nick: String) {
        // Because they got rid of parameters being vars
        var vnick = nick
        let prefix = nick.substring(to: nick.index(after: nick.startIndex))
        
        var mode = User.Mode(rawValue: prefix)
        if mode == nil {
            mode = User.Mode.None
        } else {
            vnick.remove(at: nick.startIndex)
        }
        
        let user = User(name: vnick, mode: mode!)
        
        if user.name == server!.nickname {
            user.isSelf = true
        }
        
        let otherUser = self.user(name: user.name)
        if otherUser == nil {
            // So there are no duplicates added
            users.append(user)
        }
    }
    
    func user(name: String) -> User? {
        for user in users {
            if user.name == name {
                return user
            }
        }
        return nil
    }
    
}
