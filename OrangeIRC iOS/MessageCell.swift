//
//  MessageCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/28/16.
//
//

import UIKit
import OrangeIRCCore

class MessageCell : TextViewCell {
    
    let message: MessageLogEvent
    let room: Room
    
    var delegate: MessageCellDelegate?
    
    init(message: MessageLogEvent, room: Room, showLabel: Bool) {
        self.message = message
        self.room = room
        super.init(showLabel: showLabel)
        
        textView.isScrollEnabled = false
        
        textView.text = message.contents
        let to = localized("TO_LOWERCASE")
        let attr = NSMutableAttributedString(attributedString: message.sender.coloredName(for: room))
        
        if let replyTo = message.replyTo {
            attr.append(NSAttributedString(string: " \(to) "))
            attr.append(replyTo.coloredName(for: room))
        }
        
        label.attributedText = attr
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || (action == #selector(RoomTableViewController.reply(sender:message:)) && delegate != nil){
            return true
        } else if action == #selector(RoomTableViewController.reply(recipient:message:)) && message.replyTo != nil && delegate != nil{
            return true
        } else {
            return false
        }
    }
    
    func reply(sender: User, message: MessageLogEvent) {
        delegate!.reply(sender: self.message.sender, message: self.message)
    }
    
    func reply(recipient: User, message: MessageLogEvent) {
        delegate!.reply(recipient: self.message.replyTo!, message: self.message)
    }
    
}
