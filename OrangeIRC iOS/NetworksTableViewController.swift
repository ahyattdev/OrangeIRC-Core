//
//  NetworksTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/4/17.
//
//

import UIKit
import OrangeIRCCore

class NetworksTableViewController : UITableViewController {
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = localized("NETWORKS")
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServerButton))
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: Notifications.ServerDataChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: Notifications.RoomDataChanged, object: nil)
        
        updateTableView()
    }
    
    func updateTableView() {
        if ServerManager.shared.servers.count == 0 {
            let label = UILabel()
            label.text = localized("TAP_TO_ADD_SERVER")
            label.textAlignment = .center
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
        
        tableView.reloadData()
    }
    
    func addServerButton() {
        let tvc = ServerSettingsTableViewController(style: .grouped)
        AppDelegate.showModalGlobally(tvc, style: .formSheet)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ServerManager.shared.servers.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + ServerManager.shared.servers[section].rooms.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ServerManager.shared.servers[section].displayName
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = NetworkHeaderView.loadFromNib(server: ServerManager.shared.servers[section])
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "RoomCell"
        var cell: UITableViewCell!
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: ID) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: ID)
            cell.accessoryType = .disclosureIndicator
        }
        
        let server = ServerManager.shared.servers[indexPath.section]
        
        if indexPath.row == 0 {
            // The "console"
            cell.textLabel?.text = localized("CONSOLE")
            if server.isConnected {
                cell.detailTextLabel?.text = localized("ONLINE")
            } else if server.isConnectingOrRegistering {
                cell.detailTextLabel?.text = localized("CONNECTING")
            } else {
                cell.detailTextLabel?.text = localized("OFFLINE")
            }
            
            // Set icon
            cell.imageView?.image = UIImage(named: "Console")
        } else {
            // A room
            let room = server.rooms[indexPath.row - 1]
            cell.textLabel?.text = room.displayName
            
            if let channel = room as? Channel {
                cell.imageView?.image = channel.isJoined ? UIImage(named: "ChannelOnline") : UIImage(named: "ChannelOffline")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Open the room
        let server = ServerManager.shared.servers[indexPath.section]
        
        if indexPath.row == 0 {
            let console = ConsoleTableViewController(server: server)
            AppDelegate.splitView.showDetailViewController(console, sender: nil)
        } else {
            let roomTVC = RoomTableViewController(server.rooms[indexPath.row - 1])
            AppDelegate.splitView.showDetailViewController(UINavigationController(rootViewController: roomTVC), sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // The console cell is always the first row
        return indexPath.row != 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let server = ServerManager.shared.servers[indexPath.section]
            let room = server.rooms[indexPath.row - 1]
            server.delete(room: room)
        }
    }
    
}
