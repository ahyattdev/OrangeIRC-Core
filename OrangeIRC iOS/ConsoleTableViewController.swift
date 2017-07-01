//
//  ConsoleTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/15/17.
//
//

import UIKit
import OrangeIRCCore

class ConsoleTableViewController: UITableViewController {
    
    let server: Server
    
    init(server: Server) {
        self.server = server
        
        super.init(style: .plain)
    }
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.scrollToRow(at: IndexPath(row: server.console.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return server.console.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let entry = server.console[indexPath.row]
        let label = UILabel()
        label.numberOfLines = 0
        label.text = entry.text
        if entry.sender == .Client {
            label.textColor = UIColor.orange
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(label)
        
        let top = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: cell.contentView, attribute: .topMargin, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0)
        
        let trailing = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailingMargin, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottomMargin, multiplier: 1.0, constant: 0)
        
        let width = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: cell.contentView.frame.width - cell.contentView.layoutMargins.left - cell.contentView.layoutMargins.right)
        
        bottom.priority = 500
        
        cell.contentView.addConstraints([top, bottom, leading, trailing, width])
        
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        
        return cell;
    }
    
}
