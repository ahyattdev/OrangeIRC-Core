//
//  RightDetailTextViewCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 2/25/17.
//
//

import UIKit

class RightDetailTextViewCell : UITableViewCell {
    
    var title = UILabel(), textView = UITextView(), detail = UILabel()
    
    init(_ reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        detail.textAlignment = .right
        
        contentView.addSubview(title)
        contentView.addSubview(detail)
        contentView.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let innerWidth = contentView.frame.width - separatorInset.right - separatorInset.left
        
        title.frame = CGRect(x: separatorInset.left, y: separatorInset.top, width: innerWidth / 2 - 5, height: title.frame.height)
    }
    
}
