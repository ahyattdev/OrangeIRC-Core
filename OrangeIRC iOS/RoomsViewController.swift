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
    
    let servers = (UIApplication.shared().delegate as! AppDelegate).servers
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        // Tally up the rooms of every server
        for server in self.servers {
            count += server.rooms.count
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Implement this stub
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    @IBAction func addRoom(_ sender: UIBarButtonItem) {
        let roomType = NSLocalizedString("ROOM_TYPE", comment: "Room Type")
        let roomTypeDescription = NSLocalizedString("CHOOSE_ROOM_TYPE", comment: "Choose a room type")
        let roomTypeActionSheet = UIAlertController(title: roomType, message: roomTypeDescription, preferredStyle: .actionSheet)
        
        let channelAct = UIAlertAction(title: RoomType.Channel.localizedName(), style: .default, handler: { (action) in
            self.performSegue(withIdentifier: Segues.ShowAddChannel.rawValue, sender: RoomType.Channel.rawValue)
        })
        roomTypeActionSheet.addAction(channelAct)
        
        let privateAct = UIAlertAction(title: RoomType.PrivateMessage.localizedName(), style: .default, handler: { (action) in
            self.performSegue(withIdentifier: Segues.ShowAddPrivate.rawValue, sender: RoomType.PrivateMessage.rawValue)
        })
        roomTypeActionSheet.addAction(privateAct)
        
        let cancelAct = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: { (action) in
            roomTypeActionSheet.dismiss(animated: true, completion: nil)
        })
        roomTypeActionSheet.addAction(cancelAct)
        
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
