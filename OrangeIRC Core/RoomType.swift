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

/// The type of a `Room`
public enum RoomType : String {
    
    /// IRC channel
    case Channel = "Channel"
    /// Private message session
    case PrivateMessage = "PrivateMessage"
    
    /// Gets a localized name for the room type
    ///
    /// - Returns: Localized room type
    public func localizedName() -> String {
        switch self {
        case .Channel:
            return localized("CHANNEL")
        case .PrivateMessage:
            return localized("PRIVATE_MESSAGE")
        }
    }
    
}
