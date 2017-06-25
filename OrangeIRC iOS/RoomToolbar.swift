//
//  RoomToolbar.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/12/17.
//
//

import UIKit
import OrangeIRCCore

class RoomToolbar : UIToolbar, UITextViewDelegate {
    
    var toolbarDelegate: RoomToolbarDelegate?
    
    let room: Room
    
    let contentView = UIView()
    let textView = UITextView()
    let sendButton = UIButton(type: UIButtonType.system)
    
    var bottom: NSLayoutConstraint!
    var textViewHeight: NSLayoutConstraint!
    
    init(room: Room) {
        self.room = room
        
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.scrollsToTop = false
        textView.layer.cornerRadius = 6.0
        textView.delegate = self
        
        contentView.addSubview(textView)
        contentView.addSubview(sendButton)
        
        sendButton.isEnabled = false
        sendButton.setTitle(localized("SEND"), for: .normal)
        
        sendButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
        
        items =  [UIBarButtonItem(customView: contentView)]
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0)
        
        addConstraints([height])
        
        textViewHeight = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
        textView.addConstraint(textViewHeight)
        
        let tvLeading = NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0)
        let tvTrailing = NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: sendButton, attribute: .leading, multiplier: 1.0, constant: -8)
        let tvBottom = NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottomMargin, multiplier: 1.0, constant: 0)
        contentView.addConstraints([tvLeading, tvTrailing, tvBottom])
        
        let cvLeading = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1.0, constant: 0)
        let cvTrailing = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: 0)
        let cvHeight = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: textView, attribute: .height, multiplier: 1.0, constant: 14)
        let cvBottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        addConstraints([cvLeading, cvTrailing, cvHeight, cvBottom])
        
        let sbTrailing = NSLayoutConstraint(item: sendButton, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin, multiplier: 1.0, constant: 0)
        let sbCenterY = NSLayoutConstraint(item: sendButton, attribute: .centerYWithinMargins, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins, multiplier: 1.0, constant: 0)
        contentView.addConstraints([sbTrailing, sbCenterY])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func textViewDidChange(_ textView: UITextView) {
        textViewHeight.constant = textView.contentSize.height
        superview?.setNeedsLayout()
        
        sendButton.isEnabled = textView.text.utf8.count > 0 && room.canSendMessage
    }
    
    func send() {
        toolbarDelegate?.sendButtonPressed(self)
        
        room.send(message: textView.text)
        
        textView.text = ""
    }
    
}
