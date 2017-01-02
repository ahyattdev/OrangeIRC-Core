//
//  RightDetailSubtitleCell.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/30/16.
//
//

import UIKit

class RightDetailSubtitleCell : UITableViewCell {
    
    var title = UILabel(), subtitle = UILabel(), detail = UILabel()
    
    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        subtitle.font = UIFont.systemFont(ofSize: 12)
        detail.textAlignment = .right
        
        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(detail)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleWidth = title.intrinsicContentSize.width
        let subtitleWidth = subtitle.intrinsicContentSize.width
        let detailWidth = detail.intrinsicContentSize.width
        
        let minSeperation: CGFloat = 6
        
        let maxWidth = contentView.frame.width - separatorInset.left - separatorInset.right - minSeperation
        
        var titleDestWidth = titleWidth, subtitleDestWidth = subtitleWidth, detailDestWidth = detailWidth
        
        if titleWidth + detailWidth > maxWidth || subtitleWidth + detailWidth > maxWidth {
            if titleWidth > maxWidth * (2 / 3) || subtitleWidth > maxWidth * (2 / 3) {
                titleDestWidth = titleWidth > maxWidth * (2 / 3) ? maxWidth * (2 / 3) : titleWidth
                subtitleDestWidth = subtitleWidth > maxWidth * (2 / 3) ? maxWidth * (2 / 3) : subtitleWidth
                detailDestWidth = detailWidth > maxWidth * ( 1 / 3) ? maxWidth * ( 1 / 3) : detailWidth
            } else {
                let largest = titleWidth > subtitleWidth ? titleWidth : subtitleWidth
                detailDestWidth = maxWidth - largest
            }
        }
        
        title.frame = CGRect(x: separatorInset.left, y: 5, width: titleDestWidth, height: 20.5)
        subtitle.frame = CGRect(x: separatorInset.left, y: 25.5, width: subtitleDestWidth, height: 14.5)
        detail.frame = CGRect(x: contentView.frame.width - detailDestWidth - separatorInset.right, y: 12, width: detailDestWidth, height: 20.5)
    }
    
}
