//
//  RoomToolbar.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/12/17.
//
//

import UIKit
import OrangeIRCCore

class RoomToolbar : UIToolbar {
    
    let room: Room
    
    let contentView = UIView()
    let textView = UITextView()
    let sendButton = UIBarButtonItem()
    
    var bottom: NSLayoutConstraint!
    
    init(room: Room) {
        self.room = room
        
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.scrollsToTop = false
        textView.layer.cornerRadius = 6.0
        
        contentView.addSubview(textView)
        
        items =  [UIBarButtonItem(customView: contentView)]
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let leading = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1.0, constant: 0)
        
        let trailing = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        superview?.addConstraints([leading, trailing, bottom])
    }
    
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottom.constant = -1 * keyboardSize.height
            superview?.setNeedsLayout()
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        bottom.constant = 0
        superview?.setNeedsLayout()
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
}
