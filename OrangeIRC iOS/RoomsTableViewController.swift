//
//  RoomsViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import UIKit
import OrangeIRCCore

class RoomsTableViewController : UITableViewController, UIViewControllerPreviewingDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reload the tableview when the room data changes
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notification:)), name: Notifications.RoomStateUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registerForUpdates(_:)), name: Notifications.RoomCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notification:)), name: Notifications.RoomDeleted, object: nil)
        
        title = NSLocalizedString("ROOMS", comment: "Rooms")
        
        let serversButtonTitle = NSLocalizedString("SERVERS", comment: "Servers")
        let serversButton = UIBarButtonItem(title: serversButtonTitle, style: .plain, target: self, action: #selector(self.serversButton))
        navigationItem.leftBarButtonItems = [serversButton, editButtonItem]
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRoomButton))
        navigationItem.rightBarButtonItem = addButton
        
        // Add a shortcut for adding a room
        addKeyCommand(UIKeyCommand(input: "N", modifierFlags: .command, action: #selector(addRoomButton), discoverabilityTitle: NSLocalizedString("ADD_ROOM", comment: "")))
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    func registerForUpdates(_ notification: NSNotification) {
        if let room = notification.object as? Room {
            NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notification:)), name: Notifications.RoomStateUpdated, object: room)
        }
    }
    
    func reloadTableView(notification: NSNotification) {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ServerManager.shared.rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RightDetailSubtitleCell(reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        
        let room = ServerManager.shared.rooms[indexPath.row]
        
        cell.title.text = room.name
        cell.detail.text = room.isJoined ? NSLocalizedString("JOINED", comment: "") : NSLocalizedString("NOT_JOINED", comment: "")
        cell.detail.textColor = room.isJoined ? UIColor.darkText : UIColor.lightGray
        
        cell.subtitle.text = room.server!.displayName
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let room = ServerManager.shared.rooms[indexPath.row]
        
        let roomViewController = RoomTableViewController(room)
        
        AppDelegate.splitView.showDetailViewController(UINavigationController(rootViewController: roomViewController), sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Enables the delete row button
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let room = ServerManager.shared.rooms[indexPath.row]
        
        switch editingStyle {
        case .delete:
            ServerManager.shared.delete(room: room)
        case .insert:
            break
        case .none:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Enables the move row indicators
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Move the room
        let room = ServerManager.shared.rooms.remove(at: sourceIndexPath.row)
        ServerManager.shared.rooms.insert(room, at: destinationIndexPath.row)
        
        // Post a notification and save data
        NotificationCenter.default.post(name: Notifications.RoomStateUpdated, object: nil)
        ServerManager.shared.saveData()
    }
    
    func serversButton() {
        let servers = ServersTableViewController()
        let nav = UINavigationController(rootViewController: servers)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }
    
    func addRoomButton() {
        // Make sure that there is a registered server for the room to be added on
        guard ServerManager.shared.registeredServers.count > 0 else {
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
        nav.modalPresentationStyle = .formSheet
        navigationController?.present(nav, animated: true, completion: nil)
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        let cell = tableView(tableView, cellForRowAt: indexPath)
        
        let room = ServerManager.shared.rooms[indexPath.row]
        
        let tvc = RoomTableViewController(room)
        
        // FIXME: Not at the correct height
        previewingContext.sourceRect = cell.contentView.frame
        
        let nav = UINavigationController(rootViewController: tvc)
        
        // Wrap in a navigation controller so we get a title
        return nav
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}
