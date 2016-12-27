//
//  UserInfoTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/26/16.
//
//

import UIKit
import OrangeIRCCore

class UserInfoTableViewController : UITableViewController {
    
    let rowNames = [
        [
            NSLocalizedString("CLASS", comment: ""),
            NSLocalizedString("AWAY_INFO", comment: "")
        ], [
            NSLocalizedString("IP_ADDRESS", comment: ""),
            NSLocalizedString("HOSTNAME", comment: ""),
            NSLocalizedString("USERNAME", comment: ""),
            NSLocalizedString("REAL_NAME", comment: "")
        ], [
            NSLocalizedString("SERVER", comment: ""),
            NSLocalizedString("ROOMS", comment: "")
        ], [
            NSLocalizedString("CONNECTED", comment: ""),
            NSLocalizedString("IDLE", comment: "")
        ], [
            NSLocalizedString("PING", comment: ""),
            NSLocalizedString("LOCAL_TIME", comment: ""),
            NSLocalizedString("CLIENT_INFO", comment: "")
        ]
    ]
    
    var rowData = [[String?]]()
    
    var user: User
    
    init(user: User) {
        // Populate rowData
        for i in 0 ..< rowNames.count {
            rowData.append([String?]())
            for _ in 0 ..< rowNames[i].count {
                rowData[i].append(nil)
            }
        }
        
        rowData[2][1] = "foo"
        
        self.user = user
        super.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = user.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rowNames.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowNames[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "")
        
        cell.textLabel?.text = rowNames[indexPath.section][indexPath.row]
        
        if let data = rowData[indexPath.section][indexPath.row] {
            cell.detailTextLabel?.text = data
        } else {
            let act = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            act.center = CGPoint(x: cell.contentView.bounds.width - (cell.contentView.bounds.height / 2), y: cell.contentView.bounds.height / 2)
            cell.contentView.addSubview(act)
            act.startAnimating()
        }
        
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            // Class
            break
            
        case (0, 1):
            // Away Info
            break
            
            
        case (1, 0):
            // IP
            break
            
        case (1, 1):
            // Hostname
            break
            
        case (1, 2):
            // Username
            break
            
        case (1, 3):
            // Realname
            break
            
            
        case (2, 0):
            // Server
            break
            
        case (2, 1):
            // Rooms
            break
            
        case (3, 0):
            // Time connected
            break
            
        case (3, 1):
            // Time idle
            break
            
            
        case (4, 0):
            // Ping
            break
            
        case (4, 1):
            // Local time
            break
            
        case (4, 2):
            // Client info
            break
            
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return rowData[indexPath.section][indexPath.row] != nil
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)), let data = rowData[indexPath.section][indexPath.row] {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = data
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
