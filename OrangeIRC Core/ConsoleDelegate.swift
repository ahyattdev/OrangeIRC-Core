//
//  ConsoleDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/1/17.
//
//

import Foundation

public protocol ConsoleDelegate {
    
    func newConsoleEntry(server: Server, entry: ConsoleEntry)
    
}
