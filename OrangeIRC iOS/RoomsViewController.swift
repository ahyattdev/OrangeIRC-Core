//
//  RoomsViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import UIKit
import OrangeIRCCore

class RoomsViewController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reload the tableview when the room data changes
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notification:)), name: Notifications.RoomDataDidChange, object: nil)
        
        title = NSLocalizedString("ROOMS", comment: "Rooms")
        
        let serversButtonTitle = NSLocalizedString("SERVERS", comment: "Servers")
        let serversButton = UIBarButtonItem(title: serversButtonTitle, style: .plain, target: self, action: #selector(self.serversButton))
        navigationItem.leftBarButtonItem = serversButton
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRoomButton))
        navigationItem.rightBarButtonItem = addButton
        
        // Add a shortcut for adding a room
        addKeyCommand(UIKeyCommand(input: "N", modifierFlags: .command, action: #selector(addRoomButton), discoverabilityTitle: NSLocalizedString("ADD_ROOM", comment: "")))
    }
    
    func reloadTableView(notification: NSNotification) {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        cell.accessoryType = .disclosureIndicator
        
        let room = appDelegate.rooms[indexPath.row]
        
        cell.textLabel!.text = "\(room.name) @ \(room.server!.host)"
        
        if room.isJoined {
            cell.detailTextLabel!.text = NSLocalizedString("JOINED", comment: "Not Joined")
            cell.textLabel!.textColor = UIColor.darkText
        } else {
            cell.detailTextLabel!.text = NSLocalizedString("NOT_JOINED", comment: "Not Joined")
            cell.textLabel!.textColor = UIColor.lightGray
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let room = appDelegate.rooms[indexPath.row]
        appDelegate.show(room: room)
    }
    
    func serversButton() {
        let servers = ServersViewController()
        let nav = UINavigationController(rootViewController: servers)
        modalPresentationStyle = .pageSheet
        present(nav, animated: true, completion: nil)
    }
    
    func addRoomButton() {
        // Make sure that there is a registered server for the room to be added on
        guard self.appDelegate.registeredServers.count > 0 else {
            let title = NSLocalizedString("NO_REGISTERED_SERVERS", comment: "Not connected to any registered servers")
            let message = NSLocalizedString("NO_REGISTERED_SERVERS_DESCRIPTION", comment: "No registered servers description")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let addRoom = AddRoomTableViewController(style: .grouped)
        let nav = UINavigationController(rootViewController: addRoom)
        modalPresentationStyle = .pageSheet
        present(nav, animated: true, completion: nil)
    }
    
}
