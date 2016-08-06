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
    
    public var otherUsers = [User]()
    
    public var name: String
    
    public var topic: String?
    
    public var hasTopic = true
    
    public var isJoined = false
    
    public var type: RoomType
    
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
            let type = coder.decodeObject(forKey: Coding.RoomType) as? RoomType else {
                return nil
        }
        
        self.init(name: name, type: type)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: Coding.Name)
        aCoder.encode(self.type.rawValue, forKey: Coding.RoomType)
    }
    
}
