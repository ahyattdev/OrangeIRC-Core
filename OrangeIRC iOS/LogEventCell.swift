//
//  LogEventCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/11/17.
//
//

import UIKit
import OrangeIRCCore

class LogEventCell : UITableViewCell {
    
    let logEvent: LogEvent
    
    let dateLabel = UILabel()
    
    let content = UITextView()
    
    init(logEvent: LogEvent, reuseIdentifier: String?) {
        self.logEvent = logEvent
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(content)
        
        content.isEditable = false
        content.isScrollEnabled = false
        content.isSelectable = false
        
        let font = UIFont(name: "Menlo-Regular", size: 16)
        dateLabel.font = font
        content.font = font
        
        // dateLabel.trailing
        contentView.addConstraint(NSLayoutConstraint(item: dateLabel, attribute: .trailing, relatedBy: .equal, toItem: dateLabel.superview, attribute: .leading, multiplier: 1.0, constant: 100))
        
        // dateLabel.top
        contentView.addConstraint(NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: dateLabel.superview, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 3))
        
        // content.leading
        contentView.addConstraint(NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .equal, toItem: dateLabel, attribute: .trailing, multiplier: 1.0, constant: 10))
        
        // content.top
        contentView.addConstraint(NSLayoutConstraint(item: content, attribute: .top, relatedBy: .equal, toItem: dateLabel, attribute: .top, multiplier: 1.0, constant: 0))
        
        // content.trailing
        contentView.addConstraint(NSLayoutConstraint(item: content, attribute: .trailing, relatedBy: .equal, toItem: content.superview, attribute: .trailing, multiplier: 1.0, constant: 5))
        
        // contentView.bottom
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: content, attribute: .bottom, multiplier: 1.0, constant: 3))
        
        dateLabel.text = "1:23 PM"
        
        content.text = "test message"
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
