//
//  SwitchCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 8/8/16.
//
//

import UIKit

import Foundation

@IBDesignable

class SwitchCell : UITableViewCell {
    
    let `switch` = UISwitch()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        let switchHeight = self.switch.frame.height
        let switchWidth = self.switch.frame.width
        
        let cellHeight = frame.height
        let cellWidth = frame.width
        
        let horizontalPadding: CGFloat = 13.0
        
        self.switch.frame = CGRect(x: cellWidth - switchWidth - horizontalPadding, y: (cellHeight / 2) - (switchHeight / 2), width: switchWidth, height: switchHeight)
        
        addSubview(self.switch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
