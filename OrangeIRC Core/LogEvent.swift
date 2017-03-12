//
//  Event.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation

// Sort of like a Java abstract class for now
open class LogEvent : NSObject {
    
    open var date: Date = Date()
    
    // No reason to construct this one
    internal override init() { }
    
    open var attributedDescription: NSAttributedString {
        return NSAttributedString()
    }
    
}
