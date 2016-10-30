//
//  TextViewCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 10/14/16.
//
//

import UIKit

class TextViewCell : UITableViewCell {
    
    let textView = UITextView()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        textView.isEditable = false
        
        textView.frame.origin.x = 8;
        textView.frame.origin.y = 6;
        
        contentView.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let fixedWidth = contentView.frame.size.width - 16
        let height = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)).height
        textView.frame.size = CGSize(width: fixedWidth, height: height)
    }
    
}
