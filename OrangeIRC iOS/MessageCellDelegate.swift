//
//  MessageCellDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/28/16.
//
//

import UIKit
import OrangeIRCCore

protocol MessageCellDelegate {
    
    func reply(sender: User, message: MessageLogEvent)
    
    func reply(recipient: User, message: MessageLogEvent)
    
}
