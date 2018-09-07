//
//  Event.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

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
