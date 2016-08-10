//
//  RoomNameEntryTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/29/16.
//
//

import UIKit
import OrangeIRCCore

class RoomNameEntryTableViewController : UITableViewController {
    
    enum CellIdentifiers : String {
        
        case TextFieldCell = "TextFieldCell"
        
    }
    
    var nameField: UITextField?
    
    var roomType: RoomType?
    var server: Server?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var description = NSLocalizedString("ROOM_ENTRY_TITLE", comment: "Room entry title")
        description = description.replacingOccurrences(of: "[ROOMTYPE]", with: self.roomType!.localizedName())
        self.navigationItem.title = description
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tempCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.TextFieldCell.rawValue)
        if tempCell == nil {
            tempCell = TextFieldCell(style: UITableViewCellStyle.default, reuseIdentifier: CellIdentifiers.TextFieldCell.rawValue)
        }
        let cell = tempCell as! TextFieldCell
        
        cell.label.text = NSLocalizedString("NAME", comment: "Name")
        
        if self.roomType! == RoomType.Channel {
            cell.textField.text = "#"
        }
        
        self.nameField = cell.textField
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func doneButton(_ sender: AnyObject) {
        let roomName: String! = self.nameField?.text
        
        switch self.roomType! {
        case .Channel:
            self.server!.join(channel: roomName)
        case .PrivateMessage:
            // TODO: Implement starting a private message room
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
