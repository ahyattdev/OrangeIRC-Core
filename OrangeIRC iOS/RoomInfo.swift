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
    
    struct CellIdentifiers {
        
        private init() { }
        
        static let Cell = "Cell"
        
    }
    
    var room: Room?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "\(self.room!.name) \(NSLocalizedString("INFO", comment: "Information"))"
        
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.RoomDataDidChange, object: room!)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value2, reuseIdentifier: CellIdentifiers.Cell)
        
        switch indexPath.section {
            
        case 0:
            
            switch indexPath.row {
                
            case 0:
                if room!.isJoined {
                    cell.textLabel!.textColor = UIColor.red
                    cell.textLabel!.text = NSLocalizedString("LEAVE", comment: "Leave")
                } else {
                    cell.textLabel!.textColor = UIColor.blue
                    cell.textLabel!.text = NSLocalizedString("JOIN", comment: "Join")
                }
                
            default: break
                
            }
            
        default: break
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
            
        case 0:
            
            switch indexPath.row {
                
            case 0:
                // Toggle joined or left
                if room!.isJoined {
                    room!.server!.leave(channel: room!.name)
                } else {
                    room!.server?.join(channel: room!.name)
                }
                
            default: break
                
            }
            
        default: break
            
        }
    }
    
}
