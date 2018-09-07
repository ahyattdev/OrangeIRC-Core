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

/// A private message session with another user
open class PrivateMessage : Room {
    
    fileprivate struct Coding {
        
        private init() { }
        
        static let OtherUser = "OtherUser"
        
    }
    
    /// The user that this private message session is with
    open let otherUser: User
    
    /// The display name of the private message room
    open override var displayName: String {
        return otherUser.nick
    }
    
    /// If the client is able to message the other user
    open override var canSendMessage: Bool {
        return otherUser.isOnline && server.isRegistered
    }
    
    internal init(_ otherUser: User) {
        self.otherUser = otherUser
        super.init()
    }
    
    /// Initialize using `NSCoding` APIs
    ///
    /// - Parameter coder: The coder
    public required convenience init?(coder: NSCoder) {
        guard let otherUser = coder.decodeObject(forKey: Coding.OtherUser) as? User else {
            return nil
        }
        self.init(otherUser)
    }
    
    /// Encode using `NSCoding` APIs
    ///
    /// - Parameter aCoder: The coder
    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(otherUser, forKey: Coding.OtherUser)
    }
    
    /// Send a message to the private message user
    ///
    /// - Parameter message: The message
    open override func send(message: String) {
        // FIXME: Message size limit, chunk it?
        server.write(string: "\(Command.PRIVMSG) \(otherUser.nick) :\(message)")
        let logEvent = MessageLogEvent(contents: message, sender: server.userCache.me, room: self)
        log.append(logEvent)
        server.delegate?.received(logEvent: logEvent, for: self)
    }
    
}
