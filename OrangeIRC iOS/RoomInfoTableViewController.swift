//
//  RoomInfo.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/1/16.
//
//

import UIKit
import OrangeIRCCore

class RoomInfoTableViewController : UITableViewController {
    
    var room: Room
    
    var filteredUsers = [User]()
    
    
    init(_ room: Room) {
        self.room = room
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchResultsController = UsersSearchResultsController(room, navigationController: navigationController!)
        
        title = "\(self.room.name) \(NSLocalizedString("DETAILS", comment: "Information"))"
        navigationItem.prompt = room.server!.host
        
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.RoomDataDidChange, object: room)
        
        if room.type == .Channel {
            tableView.tableHeaderView = searchResultsController.searchController.searchBar
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if room.type == .Channel {
            if room.hasCompleteUsersList {
                return 2
            } else {
                return 1
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if room.type == .Channel {
            
            switch section {
            case 0:
                return 2
            case 1:
                return room.users.count
            default:
                return super.tableView(tableView, numberOfRowsInSection: section)
            }
            
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        if room.type == .Channel {
            
            switch indexPath.section {
                
            case 0:
                
                switch indexPath.row {
                    
                case 0:
                    if !room.server!.isRegistered {
                        cell.textLabel!.textColor = UIColor.orange
                        cell.textLabel!.text = NSLocalizedString("CONNECT_AND_JOIN", comment: "Join")
                    } else if room.isJoined {
                        cell.textLabel!.textColor = UIColor.red
                        cell.textLabel!.text = NSLocalizedString("LEAVE", comment: "Leave")
                    } else {
                        cell.textLabel!.textColor = UIColor.orange
                        cell.textLabel!.text = NSLocalizedString("JOIN", comment: "Join")
                    }
                    
                case 1:
                    // The autojoin switch
                    let switchCell = SwitchCell()
                    
                    switchCell.switch.isOn = room.autoJoin
                    
                    switchCell.switch.addTarget(self, action: #selector(autojoinPress(sender:event:)), for: .touchUpInside)
                    
                    switchCell.textLabel!.text = NSLocalizedString("AUTOMATICALLY_JOIN", comment: "")
                    
                    return switchCell
                    
                default: break
                    
                }
                
            case 1:
                // The users list
                let user = room.users[indexPath.row]
                cell.textLabel!.text = user.name
                
                cell.textLabel!.textColor = user.color(room: room)
                
                cell.accessoryType = .disclosureIndicator
                
            default: break
                
            }
            
        } else {
            
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if room.type == .Channel {
            
            switch section {
                
            case 0:
                // Topic
                if room.hasTopic {
                    return room.topic!
                }
                
            case 1:
                // Users
                return "\(room.users.count) \(NSLocalizedString("USERS_ONLINE", comment: ""))"
                
            default:
                return nil
                
            }
            
            return nil
            
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if room.type == .Channel {

            switch indexPath.section {
                
            case 0:
                
                switch indexPath.row {
                    
                case 0:
                    // Toggle joined or left
                    if !room.server!.isRegistered {
                        room.joinOnConnect = true
                        room.server!.connect()
                    } else if room.isJoined {
                        room.server!.leave(channel: room.name)
                    } else {
                        room.server?.join(channel: room.name)
                    }
                default: break
                    
                }
                
            case 1:
                // User list
                let user = room.users[indexPath.row]
                let userInfo = UserInfoTableViewController(user: user, server: room.server!)
                navigationController?.pushViewController(userInfo, animated: true)
                
            default: break
                
            }
            
        } else {
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if room.type == .Channel {
            return
                (indexPath.section == 0 && indexPath.row == 0) || // Join button
                (indexPath.section == 1) // Users list
        } else {
            return false
        }
    }
    
    func autojoinPress(sender: UISwitch, event: UIControlEvents) {
        room.autoJoin = sender.isOn
        ServerManager.shared.saveData()
    }
    
}
