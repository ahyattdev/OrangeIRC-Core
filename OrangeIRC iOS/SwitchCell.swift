//
//  SwitchCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 8/8/16.
//
//

import UIKit

class SwitchCell : UITableViewCell {
    
    let `switch` = UISwitch()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        contentView.addSubview(self.switch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.switch.frame.origin = CGPoint(x: contentView.frame.width - self.switch.frame.width - separatorInset.left - separatorInset.right, y: (contentView.frame.height - self.switch.frame.height) / 2)
        
        
        if let textLabel = textLabel {
            let otherWidth = separatorInset.left + separatorInset.right + self.switch.frame.width + 6
            if textLabel.intrinsicContentSize.width > otherWidth {
                textLabel.frame.size.width = contentView.frame.width - otherWidth
            }
        }
    }
    
}
