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
    
    enum Segues : String {
        
        case ShowServers = "ShowServers"
        case ShowAddChannel = "ShowAddChannel"
        case ShowAddPrivate = "ShowAddPrivate"
        case ShowRoom = "ShowRoom"
        
    }
    
    enum CellIdentifiers : String {
        case Cell = "Cell"
    }
    
    var allRooms = [Room]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reload the tableview when the room data changes
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notification:)), name: Notifications.RoomDataDidChange, object: nil)
        
        self.navigationItem.title = NSLocalizedString("ROOMS", comment: "Rooms")
        self.navigationItem.leftBarButtonItem?.title = NSLocalizedString("SERVERS", comment: "Servers")
        
        appDelegate.roomsView = self
    }
    
    func reloadTableView(notification: NSNotification) {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.allRooms = [Room]()
        
        for server in self.appDelegate.servers {
            for room in server.rooms {
                self.allRooms.append(room)
            }
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allRooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tempCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.Cell.rawValue)
        if tempCell == nil {
            tempCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: CellIdentifiers.Cell.rawValue)
        }
        let cell = tempCell!
        
        let room = self.allRooms[indexPath.row]
        
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
    
    @IBAction func addRoom(_ sender: UIBarButtonItem) {
        // There is no point in showing this if there are not any connected servers
        guard self.appDelegate.registeredServers.count > 0 else {
            let title = NSLocalizedString("NO_REGISTERED_SERVERS", comment: "Not connected to any registered servers")
            let message = NSLocalizedString("NO_REGISTERED_SERVERS_DESCRIPTION", comment: "No registered servers description")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let roomType = NSLocalizedString("ROOM_TYPE", comment: "Room Type")
        let roomTypeDescription = NSLocalizedString("CHOOSE_ROOM_TYPE", comment: "Choose a room type")
        let roomTypeActionSheet = UIAlertController(title: roomType, message: roomTypeDescription, preferredStyle: .actionSheet)
        
        let channelAct = UIAlertAction(title: RoomType.Channel.localizedName(), style: .default, handler: { (action) in
            self.performSegue(withIdentifier: Segues.ShowAddChannel.rawValue, sender: RoomType.Channel.rawValue)
            self.navigationItem.leftBarButtonItem!.isEnabled = true
        })
        roomTypeActionSheet.addAction(channelAct)
        
        let privateAct = UIAlertAction(title: RoomType.PrivateMessage.localizedName(), style: .default, handler: { (action) in
            self.performSegue(withIdentifier: Segues.ShowAddPrivate.rawValue, sender: RoomType.PrivateMessage.rawValue)
            self.navigationItem.leftBarButtonItem!.isEnabled = true
        })
        roomTypeActionSheet.addAction(privateAct)
        
        let cancelAct = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: { (action) in
            roomTypeActionSheet.dismiss(animated: true, completion: nil)
            self.navigationItem.leftBarButtonItem!.isEnabled = true
        })
        roomTypeActionSheet.addAction(cancelAct)
        
        // To get the action sheet to be centered on the button that triggers it
        roomTypeActionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        // Make the left bar button disabled while the action sheet is presented
        self.navigationItem.leftBarButtonItem!.isEnabled = false
        
        self.present(roomTypeActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func serversButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: Segues.ShowServers.rawValue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Segues.ShowAddChannel.rawValue:
            let nav = segue.destination as! AddRoomServerSelectionNavigation
            nav.roomType = RoomType.Channel
        case Segues.ShowAddPrivate.rawValue:
            let nav = segue.destination as! AddRoomServerSelectionNavigation
            nav.roomType = RoomType.PrivateMessage
        case Segues.ShowRoom.rawValue:
            let room = sender as? Room
            let roomViewController = segue.destination as! RoomViewController
            roomViewController.updateWith(room: room)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let room = self.allRooms[indexPath.row]
        appDelegate.show(room: room)
    }
    
}
