//
//  Server+Log.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import Foundation

// The code for managing a server-wide and channel logs
extension Server {
    
    func add(entry: LogEvent, channel: String) {
        if self.logs[channel] == nil {
            self.logs[channel] = [LogEvent]()
        }
        self.logs[channel]!.append(entry)
    }
}
