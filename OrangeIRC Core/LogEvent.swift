//
//  Event.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

// Sort of like a Java abstract class for now
open class LogEvent : NSObject {
    
    open var date: Date = Date()
    
    // No reason to construct this one
    internal override init() { }

    #if os(iOS) || os(tvOS)
    
    open static var attributes = [NSFontAttributeName : UIFont(name: "Menlo-Regular", size: 16) as Any]
    
    open static var italicAttributes = [NSFontAttributeName : UIFont(name: "Menlo-Italic", size: 16) as Any]
    
    #else
    
    open static var attributes = [NSFontAttributeName : NSFont(name: "Menlo-Regular", size: 16) as Any]
    
    open static var italicAttributes = [NSFontAttributeName : NSFont(name: "Menlo-Italic", size: 16) as Any]
    
    #endif
    
    open var attributedDescription: NSAttributedString {
        return NSAttributedString(string: String(describing: self), attributes: LogEvent.attributes)
    }
    
}
