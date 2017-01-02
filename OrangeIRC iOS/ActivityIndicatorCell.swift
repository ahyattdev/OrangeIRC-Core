//
//  ActivityIndicatorCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 1/1/17.
//
//

import UIKit

class ActivityIndicatorCell: UITableViewCell {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activityIndicator.frame.origin = CGPoint(x: contentView.frame.width - separatorInset.left - separatorInset.right - activityIndicator.frame.width, y: (contentView.frame.height - activityIndicator.frame.height) / 2)
    }
    
}
