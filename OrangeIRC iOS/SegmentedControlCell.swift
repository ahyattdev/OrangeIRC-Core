//
//  UISegmentedControlCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/29/16.
//
//

import UIKit

class SegmentedControlCell : UITableViewCell {
    
    let segmentedControl = UISegmentedControl()
    
    init(segments: [String], target: AnyObject?, action: Selector?) {
        for i in 0 ..< segments.count {
            segmentedControl.insertSegment(withTitle: segments[i], at: i, animated: false)
        }
        
        if action != nil {
            segmentedControl.addTarget(target, action: action!, for: .valueChanged)
        }
        
        super.init(style: .default, reuseIdentifier: "")
        
        contentView.addSubview(segmentedControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        segmentedControl.frame = CGRect(x: 16, y: 3, width: contentView.frame.width - 32, height: contentView.frame.height - 6)
    }
    
}
