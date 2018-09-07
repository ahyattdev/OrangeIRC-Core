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

/// An IRC room. It is either a `Channel` or `PrivateMessage` at runtime.
open class Room : NSObject, NSCoding {
    
    // Should be set by the AppDelegate or ServerManager when the room is loaded or created
    /// The `Server` the room belongs to
    open var server: Server!
    
    /// The log of the room
    open var log = [LogEvent]()
    
    /// The display name of the room
    open var displayName: String {
        return ""
    }
    
    /// If the client is able to send messages to the room
    open var canSendMessage: Bool {
        return false
    }
    
    // This is basically an "abstract class"
    internal override init() { }
    
    /// Initialize using `NSCoding` APIs
    ///
    /// - Parameter coder: The coder
    public required convenience init?(coder: NSCoder) {
        self.init()
    }
    
    /// Encode using `NSCoding` APIs
    ///
    /// - Parameter aCoder: The coder
    open func encode(with aCoder: NSCoder) {

    }
    
    /// Send a message to the room
    ///
    /// - Parameter message: The message
    open func send(message: String) {
        fatalError("This should be overriden by subclasses")
    }
    
}
