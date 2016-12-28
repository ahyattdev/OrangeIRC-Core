//
//  TextViewCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 10/14/16.
//
//

import UIKit

class TextViewCell : UITableViewCell {
    
    let label = UILabel()
    let textView = UITextView()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 17)
        
        label.font = UIFont.systemFont(ofSize: 12)
        
        contentView.addSubview(textView)
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textView.frame.size = textView.sizeThatFits(CGSize(width: contentView.frame.width - 32, height: contentView.frame.height - 17))
        
        textView.frame.origin = CGPoint(x: 16, y: 17)
        
        label.frame = CGRect(x: 16, y: 6, width: contentView.frame.width - 32, height: 12)
    }
    
    static func getHeight(_ text: String, width: CGFloat) -> CGFloat {
        return getHeight(attributedText: NSAttributedString(string: text), width: width)
    }
    
    static func getHeight(attributedText: NSAttributedString, width: CGFloat) -> CGFloat {
        let offset = 18 as CGFloat
        
        let dummyTextView = UITextView()
        dummyTextView.attributedText = attributedText
        dummyTextView.font = UIFont.systemFont(ofSize: 17)
        let size = dummyTextView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        return size.height + offset
    }
    
}
