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
        textView.font = UIFont.systemFont(ofSize: 17)
        
        textView.frame.origin.x = 8;
        textView.frame.origin.y = 6;
        
        contentView.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.center = CGPoint(x: 0.5, y: 0.5)
        let width = contentView.frame.width - 16
        let height = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        textView.frame = CGRect(x: contentView.frame.midX, y: contentView.frame.midY, width: width, height: height)
    }
    
}
