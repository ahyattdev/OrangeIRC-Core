//
//  AddRoomServerSelection.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/29/16.
//
//

import UIKit
import OrangeIRCCore

class AddRoomServerSelection : UITableViewController {
    
    enum Segues : String {
        
        case RoomNameEntrySegue = "RoomNameEntrySegue"
        
    }
    // Cache the registered servers for speed and thread safety
    var registeredServers: [Server]?
    
    enum CellIdentifiers : String {
        
        case Cell = "Cell";
        
    }
    
    var roomType: RoomType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // A server could potentially disconnect or connect while this dialog is shown
        NotificationCenter.default.addObserver(self.tableView, selector: #selector(self.tableView.reloadData), name: NSNotification.Name(rawValue: Notifications.ServerDataDidChange), object: nil)
        
        let nav = self.navigationController as! AddRoomServerSelectionNavigation
        self.roomType = nav.roomType!
        
        self.navigationItem.title = NSLocalizedString("SELECT_SERVER", comment: "Select a server")
        
        var description = NSLocalizedString("JOIN_DESCRIPTION", comment: "Join description")
        description = description.replacingOccurrences(of: "[ROOMTYPE]", with: self.roomType!.localizedName().lowercased())
        self.navigationItem.prompt = description
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.registeredServers = self.appDelegate.registeredServers
        return self.registeredServers!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tempCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.Cell.rawValue)
        if tempCell == nil {
            tempCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: CellIdentifiers.Cell.rawValue)
        }
        let cell = tempCell!
        
        // Display every conencted server for selection
        let server = self.registeredServers![indexPath.row]
        cell.textLabel?.text = server.host
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let server = self.registeredServers![indexPath.row]
        self.performSegue(withIdentifier: Segues.RoomNameEntrySegue.rawValue, sender: server)
    }
    
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Segues.RoomNameEntrySegue.rawValue:
            let roomEntry = segue.destination as! RoomNameEntryTableViewController
            roomEntry.roomType = self.roomType
            roomEntry.server = sender as? Server
        default:
            break
        }
    }
    
}
