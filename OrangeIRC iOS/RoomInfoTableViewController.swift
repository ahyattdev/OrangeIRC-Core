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
        
        if let channel = room as? Channel, let nav = navigationController {
            let searchResultsController = UsersSearchResultsController(channel, navigationController: nav)
            tableView.tableHeaderView = searchResultsController.searchController.searchBar
        }
        
        
        title = "\(room.displayName) \(localized("DETAILS"))"
        navigationItem.prompt = room.server!.displayName
        
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.RoomStateUpdated, object: room)
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.TopicUpdatedForRoom, object: room)
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.UserListUpdatedForRoom, object: room)

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let channel = room as? Channel {
            if channel.hasCompleteUsersList {
                return 2
            } else {
                return 1
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let channel = room as? Channel {
            
            switch section {
            case 0:
                return 2
            case 1:
                return channel.users.count
            default:
                return super.tableView(tableView, numberOfRowsInSection: section)
            }
            
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        if let channel = room as? Channel {
            
            switch indexPath.section {
                
            case 0:
                
                switch indexPath.row {
                    
                case 0:
                    if !room.server!.isRegistered {
                        cell.textLabel!.textColor = UIColor.orange
                        cell.textLabel!.text = localized("CONNECT_AND_JOIN")
                    } else if channel.isJoined {
                        cell.textLabel!.textColor = UIColor.red
                        cell.textLabel!.text = localized("LEAVE")
                    } else {
                        cell.textLabel!.textColor = UIColor.orange
                        cell.textLabel!.text = localized("JOIN")
                    }
                    
                case 1:
                    // The autojoin switch
                    let switchCell = SwitchCell()
                    
                    switchCell.switch.isOn = channel.autoJoin
                    
                    switchCell.switch.addTarget(self, action: #selector(autojoinPress(sender:event:)), for: .touchUpInside)
                    
                    switchCell.textLabel!.text = localized("AUTOMATICALLY_JOIN")
                    
                    return switchCell
                    
                default: break
                    
                }
                
            case 1:
                // The users list
                let user = channel.users[indexPath.row]
                cell.textLabel!.text = user.nick
                
                cell.textLabel!.textColor = user.color(room: room)
                
                cell.accessoryType = .disclosureIndicator
                
            default: break
                
            }
            
        } else {
            
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let channel = room as? Channel {
            
            switch section {
                
            case 0:
                // Topic
                if channel.hasTopic {
                    return channel.topic!
                }
                
            case 1:
                // Users
                return "\(channel.users.count) \(localized("USERS_ONLINE"))"
                
            default:
                return nil
                
            }
            
            return nil
            
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let channel = room as? Channel {

            switch indexPath.section {
                
            case 0:
                
                switch indexPath.row {
                    
                case 0:
                    // Toggle joined or left
                    if !room.server!.isRegistered {
                        channel.joinOnConnect = true
                        room.server!.connect()
                    } else if channel.isJoined {
                        room.server!.leave(channel: channel.name)
                    } else {
                        room.server?.join(channel: channel.name)
                    }
                default: break
                    
                }
                
            case 1:
                // User list
                let user = channel.users[indexPath.row]
                let userInfo = UserInfoTableViewController(user: user, server: room.server!)
                navigationController?.pushViewController(userInfo, animated: true)
                
            default: break
                
            }
            
        } else {
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if room is Channel {
            return
                (indexPath.section == 0 && indexPath.row == 0) || // Join button
                (indexPath.section == 1) // Users list
        } else {
            return false
        }
    }
    
    func autojoinPress(sender: UISwitch, event: UIControlEvents) {
        if let channel = room as? Channel {
            channel.autoJoin = sender.isOn
            ServerManager.shared.saveData()
        }
    }
    
}
