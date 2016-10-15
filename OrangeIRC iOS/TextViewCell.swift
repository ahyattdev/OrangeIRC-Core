//
//  TextViewCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 10/14/16.
//
//

import UIKit

class TextViewCell : UITableViewCell {
    
    var contents: String {
        get {
            return textView.text
        }
        set {
            textView.text = contents
            
            let fixedWidth = textView.frame.size.width - 16
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            textView.frame = newFrame;
        }
    }
    
    private let textView = UITextView()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        textView.frame.origin.x = 8;
        textView.frame.origin.y = 6;
        
        addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
