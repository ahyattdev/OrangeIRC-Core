//
//  AppDelegate+Color.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/3/16.
//
//

import UIKit
import OrangeIRCCore

extension AppDelegate {
    
    func color(for user: User, in room: Room) -> UIColor {
        var color = UIColor.black
        switch user.mode {
        case .Operator:
            color = UIColor.red
        case .Voice:
            color = UIColor.blue
        case .Invisible:
            color = UIColor.gray
        case .Deaf:
            color = UIColor.lightGray
        case .Zombie:
            color = UIColor.gray
        case .None:
            // Default text color
            break
        }
        
        if !room.isJoined {
            color = UIColor.lightGray
        }
        
        if user.isSelf {
            color = UIColor.orange
        }
        
        return color
    }
}
