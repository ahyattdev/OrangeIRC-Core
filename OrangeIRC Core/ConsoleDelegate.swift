//
//  ConsoleDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/1/17.
//
//

import Foundation

/// The delegate for a server’s console
public protocol ConsoleDelegate {
    
    /// A new entry is available in the console log
    func newConsoleEntry(server: Server, entry: ConsoleEntry)
    
}
