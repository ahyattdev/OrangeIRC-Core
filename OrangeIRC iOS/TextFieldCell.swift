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
    
    var HORIZONTAL_SPACE: CGFloat {
        get {
            return contentView.frame.width - 16
        }
    }
    
    let textField = UITextField()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        contentView.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let offset: CGFloat = 125
        textField.frame.origin.x = offset
        textField.frame.origin.y = 6
        textField.frame.size.height = contentView.frame.height - 12
        textField.frame.size.width = contentView.frame.width - offset - 8
    }
    
}
