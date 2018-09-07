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

/// When a user is kicked from a channel
public class KickLogEvent : ModerationLogEvent {
    
    /// Attributed description
    public override var attributedDescription: NSAttributedString {
        let str = NSMutableAttributedString()
        str.append(receiver.coloredName(for: room))
        str.append(NSAttributedString(string: " \(localized("WAS_KICKED_BY")) "))
        str.append(sender.coloredName(for: room))
        str.addAttributes(LogEvent.italicAttributes, range: NSRange(location: 0, length: str.length))
        return str
    }
    
}
