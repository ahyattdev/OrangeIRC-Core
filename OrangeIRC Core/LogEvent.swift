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

// Necessary because of UIFont and NSFont
#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

/// An event in a room log. More detail is given in it’s subtypes. This class is
/// sort of like a Java abstract class inthe way it’s used.
public class LogEvent : NSObject {
    
    /// The `Date` for the log event
    public var date: Date = Date()
    
    // No reason to construct this one
    internal override init() { }

    // Necessary because of UIFont and NSFont
    #if os(macOS)
    
    /// For default log event description text
    public static var attributes = [NSAttributedStringKey.font : NSFont(name: "Menlo-Regular", size: 16) as Any]
    
    /// For italic log event description text
    public static var italicAttributes = [NSAttributedStringKey.font : NSFont(name: "Menlo-Italic", size: 16) as Any]
    
    #else
    
    /// For default log event description text
    public static var attributes = [NSAttributedStringKey.font : UIFont(name: "Menlo-Regular", size: 16) as Any]
    
    /// For italic log event description text
    public static var italicAttributes = [NSAttributedStringKey.font : UIFont(name: "Menlo-Italic", size: 16) as Any]
    
    #endif
    
    /// A textual representation of the log event with string attributes.
    public var attributedDescription: NSAttributedString {
        return NSAttributedString(string: String(describing: self), attributes: LogEvent.attributes)
    }
    
}
