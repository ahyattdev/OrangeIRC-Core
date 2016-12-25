//
//  AddRoomTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 10/3/16.
//
//

import UIKit
import OrangeIRCCore

class AddRoomTableViewController : UITableViewController {
    
    var autoJoinSetting = false
    var selectedServer: Server?
    var selectedRoomType: RoomType = .Channel
    var roomNameField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        
        title = NSLocalizedString("ADD_ROOM", comment: "")
        
        // Close this when the escape key is pressed
        addKeyCommand(UIKeyCommand(input: UIKeyInputEscape, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(cancel), discoverabilityTitle: NSLocalizedString("CANCEL", comment: "")))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        roomNameField!.becomeFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Server to create the room on
            return appDelegate.registeredServers.count
        case 1:
            // Room type
            return 2
        case 2:
            // Room name and autojoin
            return 2
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("SERVER", comment: "")
        case 1:
            return NSLocalizedString("ROOM_TYPE", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("ADD_ROOM_SERVER_SECTION_DESCRIPTION", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            let server = appDelegate.registeredServers[indexPath.row]
            
            if indexPath.row == 0 && selectedServer == nil {
                selectedServer = server
            }
            
            if server == selectedServer! {
                cell.accessoryType = .checkmark
            }
            
            cell.textLabel!.text = server.host
            
            return cell
        case 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            switch indexPath.row {
            case 0:
                cell.accessoryType = selectedRoomType == .Channel ? .checkmark : .none
                cell.textLabel!.text = RoomType.Channel.localizedName()
            case 1:
                cell.accessoryType = selectedRoomType == .PrivateMessage ? .checkmark : .none
                cell.textLabel!.text = RoomType.PrivateMessage.localizedName()
            default:
                break
            }
            
            return cell
            
        case 2:
            switch indexPath.row {
            case 0:
                let cell = TextFieldCell()
                roomNameField = cell.textField
                roomNameField!.placeholder = NSLocalizedString("REQUIRED", comment: "")
                cell.textLabel!.text = NSLocalizedString("ROOM_NAME", comment: "")
                roomNameField!.autocorrectionType = .no
                roomNameField!.autocapitalizationType = .none
                return cell
                
            case 1:
                let cell = SwitchCell()
                cell.textLabel!.text = NSLocalizedString("AUTOMATICALLY_JOIN", comment: "")
                cell.switch.isOn = autoJoinSetting
                cell.switch.addTarget(self, action: #selector(autojoinSwitchFlip(sender:event:)), for: .touchUpInside)
                return cell
                
            default:
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
            
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            // The server list
            selectedServer = appDelegate.registeredServers[indexPath.row]
            
            tableView.reloadSections(IndexSet(0 ..< 1), with: .automatic)
            
        case 1:
            // The room type
            switch indexPath.row {
            case 0:
                selectedRoomType = .Channel
            case 1:
                selectedRoomType = .PrivateMessage
            default:
                break
            }
            
            tableView.reloadSections(IndexSet(1 ..< 2), with: .automatic)
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0, 1:
            return true
        default:
            return false
        }
    }
    
    func autojoinSwitchFlip(sender: UISwitch, event: UIControlEvents) {
        autoJoinSetting = sender.isOn
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func done() {
        guard roomNameField != nil && roomNameField!.text != nil && !roomNameField!.text!.isEmpty else {
            let title = NSLocalizedString("INVALID_ROOM_NAME", comment: "")
            let message = NSLocalizedString("INVALID_ROOM_NAME_MESSAGE", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let name = roomNameField!.text!
        let server = selectedServer!
        
        if selectedRoomType == .Channel && !Server.ValidChannelPrefixes.characterIsMember(unichar(name.utf8.first!)) {
            let title = NSLocalizedString("INVALID_ROOM_NAME", comment: "")
            let message = NSLocalizedString("MISSING_CHANNEL_PREFIX", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        
        if autoJoinSetting {
            server.roomsFlaggedForAutoJoin.append(name)
        }
        
        switch selectedRoomType {
        case .Channel:
            server.join(channel: name)
        case .PrivateMessage:
            break
        }
        
        dismiss(animated: true, completion: nil)
    }
}
