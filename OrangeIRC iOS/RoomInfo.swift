//
//  RoomInfo.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/1/16.
//
//

import UIKit
import OrangeIRCCore

class RoomInfo : UITableViewController {
    
    var room: Room?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(self.room!.name) \(NSLocalizedString("DETAILS", comment: "Information"))"
        navigationItem.prompt = room!.server!.host
        
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.RoomDataDidChange, object: room!)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if room != nil && room!.hasCompleteUsersList {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return room!.users.count
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
            
        case 0:
            
            switch indexPath.row {
                
            case 0:
                if !room!.server!.isRegistered {
                    cell.textLabel!.textColor = UIColor.orange
                    cell.textLabel!.text = NSLocalizedString("CONNECT_AND_JOIN", comment: "Join")
                } else if room!.isJoined {
                    cell.textLabel!.textColor = UIColor.red
                    cell.textLabel!.text = NSLocalizedString("LEAVE", comment: "Leave")
                } else {
                    cell.textLabel!.textColor = UIColor.orange
                    cell.textLabel!.text = NSLocalizedString("JOIN", comment: "Join")
                }
                
            case 1:
                // The autojoin switch
                let switchCell = SwitchCell()
                
                switchCell.switch.isOn = room!.autoJoin
                
                switchCell.switch.addTarget(self, action: #selector(autojoinPress(sender:event:)), for: .touchUpInside)
                
                switchCell.textLabel!.text = NSLocalizedString("AUTOMATICALLY_JOIN", comment: "")
                
                return switchCell
                
            default: break
                
            }
        
        case 1:
            // The users list
            let user = room!.users[indexPath.row]
            cell.textLabel!.text = user.name
            
            cell.textLabel!.textColor = user.color(room: room!)
            
            cell.accessoryType = .disclosureIndicator
            
        default: break
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            // Topic
            if room != nil {
                if room!.hasTopic {
                    return room!.topic!
                }
            }
        case 1:
            // Users
            return "\(room!.users.count) \(NSLocalizedString("USERS_ONLINE", comment: ""))"
        default:
            break
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
            
        case 0:
            
            switch indexPath.row {
                
            case 0:
                // Toggle joined or left
                if !room!.server!.isRegistered {
                    room!.joinOnConnect = true
                    room!.server!.connect()
                } else if room!.isJoined {
                    room!.server!.leave(channel: room!.name)
                } else {
                    room!.server?.join(channel: room!.name)
                }
            default: break
                
            }
            
        case 1:
            // User list
            let user = room!.users[indexPath.row]
            let userInfo = UserInfoTableViewController(user: user)
            navigationController?.pushViewController(userInfo, animated: true)
            
        default: break
            
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row == 1 {
            return false
        }
        
        return true
    }
    
    func autojoinPress(sender: UISwitch, event: UIControlEvents) {
        room!.autoJoin = sender.isOn
        appDelegate.saveData()
    }
    
}
