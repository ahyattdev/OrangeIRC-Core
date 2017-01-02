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
    
    let showLabel: Bool
    init(showLabel: Bool) {
        self.showLabel = showLabel
        super.init(style: .default, reuseIdentifier: nil)
        
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.font = UIFont.systemFont(ofSize: 17)
        
        contentView.addSubview(textView)
        
        if showLabel {
            contentView.addSubview(label)
            
            label.font = UIFont.systemFont(ofSize: 12)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let txtOffset: CGFloat = showLabel ? 17 : 3
        
        textView.frame.size = textView.sizeThatFits(CGSize(width: contentView.frame.width - 32, height: contentView.frame.height - txtOffset))
        
        textView.frame.size.width = contentView.frame.width - separatorInset.left - separatorInset.right
        
        textView.frame.origin = CGPoint(x: separatorInset.left, y: txtOffset)
        
        label.frame = CGRect(x: separatorInset.left, y: 6, width: contentView.frame.width - separatorInset.left - separatorInset.right, height: 12)
    }
    
    static func getHeight(_ text: String, width: CGFloat, showLabel: Bool) -> CGFloat {
        return getHeight(attributedText: NSAttributedString(string: text), width: width, showLabel: showLabel)
    }
    
    static func getHeight(attributedText: NSAttributedString, width: CGFloat, showLabel: Bool) -> CGFloat {
        let offset = showLabel ? 18 as CGFloat : 6
        
        let dummyTextView = UITextView()
        dummyTextView.attributedText = attributedText
        dummyTextView.font = UIFont.systemFont(ofSize: 17)
        let size = dummyTextView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return size.height + offset
    }
    
}
