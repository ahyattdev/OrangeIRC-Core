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
    }
    
    enum CellIdentifiers : String {
        case Cell = "Cell"
    }
    
    var allRooms = [Room]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reload the tableview when the room data changes
        NotificationCenter.default.addObserver(self.tableView, selector: #selector(self.tableView.reloadData), name: NSNotification.Name(rawValue: Notifications.RoomDataDidChange), object: nil)
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
        
        cell.textLabel?.text = room.name
        
        cell.detailTextLabel?.text = room.server.host
        
        return cell
    }
    
    @IBAction func addRoom(_ sender: UIBarButtonItem) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Segues.ShowAddChannel.rawValue:
            let nav = segue.destinationViewController as! AddRoomServerSelectionNavigation
            nav.roomType = RoomType.Channel
        case Segues.ShowAddPrivate.rawValue:
            let nav = segue.destinationViewController as! AddRoomServerSelectionNavigation
            nav.roomType = RoomType.PrivateMessage
        default:
            break
        }
    }
    
}
