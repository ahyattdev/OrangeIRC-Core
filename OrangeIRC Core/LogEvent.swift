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
    import Foundation
#endif

// Sort of like a Java abstract class for now
open class LogEvent : NSObject {
    
    open var date: Date = Date()
    
    // No reason to construct this one
    internal override init() { }
    
    open static var attributes = [NSFontAttributeName : UIFont(name: "Menlo-Regular", size: 16) as Any]
    
    open static var italicAttributes = [NSFontAttributeName : UIFont(name: "Menlo-Italic", size: 16) as Any]
    
    open var attributedDescription: NSAttributedString {
        return NSAttributedString(string: "", attributes: LogEvent.attributes)
    }
    
}
