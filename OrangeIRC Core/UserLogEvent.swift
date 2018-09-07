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

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import Foundation
#endif

/// Parent class for log events relating to users
public class UserLogEvent : RoomLogEvent {
    
    /// The user that did the action
    public var sender: User
    
    internal init(sender: User, room: Room) {
        self.sender = sender
        super.init(room: room)
    }
    
}
