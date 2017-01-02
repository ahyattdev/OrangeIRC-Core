//
//  TextFieldCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import UIKit
@IBDesignable

class TextFieldCell : UITableViewCell {
    
    var textField = UITextField()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        contentView.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let textLabel = textLabel {
            // There is a label, and it should take up 2/5
            let separation: CGFloat = 6
            let labelWidth = (contentView.frame.width - separatorInset.left - separatorInset.right) * 0.4 - separation
            let fieldWidth = (contentView.frame.width - separatorInset.left - separatorInset.right) * 0.6 - separation
            textLabel.frame = CGRect(x: separatorInset.left, y: (contentView.frame.height - textLabel.frame.height) / 2, width: labelWidth, height: textLabel.frame.height)
            
            textField.frame = CGRect(x: labelWidth + separation + separatorInset.left, y: separatorInset.top, width: fieldWidth, height: contentView.frame.height - separatorInset.top - separatorInset.bottom)
        } else {
            // There is no label. Take up the whole cell. 
            textField.frame = CGRect(x: separatorInset.right, y: (contentView.frame.height - textField.frame.height) / 2, width: contentView.frame.width - separatorInset.left - separatorInset.right, height: textField.frame.height)
        }
    }
    
}
