//
//  RoomViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import UIKit
import OrangeIRCCore

class RoomViewController : UITableViewController {
    
    var room: Room?
    
    var composerButton: UIBarButtonItem?
    
    var detailButton: UIBarButtonItem?
    
    private var heights = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        composerButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(showMessageComposer))
        detailButton = UIBarButtonItem(title: NSLocalizedString("DETAILS", comment: "Details"), style: .plain, target: self, action: #selector(showRoomInfo))
        
        navigationItem.rightBarButtonItems = [detailButton!, composerButton!]
        
        updateButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: Notifications.DisplayedRoomDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(roomDataChanged(_:)), name: Notifications.RoomDataDidChange, object: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func handle(_ notification: NSNotification) {
        switch notification.name {
        case Notifications.DisplayedRoomDidChange:
            updateWith(room: notification.object)
        default: break
        }
    }
    
    func roomDataChanged(_ notification: NSNotification) {
        updateButtons()
    }
    
    func updateButtons() {
        // Only enable the composer button when a message can be sent
        if room == nil {
            composerButton!.isEnabled = false
            detailButton!.isEnabled = false
        } else {
            composerButton!.isEnabled = room!.server!.isRegistered && room!.isJoined
            detailButton!.isEnabled = true
        }
    }
    
    func updateWith(room: Any?) {
        // Only run this on iPad
        if !appDelegate.splitView.isCollapsed && navigationController!.visibleViewController != self {
            navigationController!.popToViewController(self, animated: true)
        }
        
        if self.room != nil {
            // Stop observing the old room
            NotificationCenter.default.removeObserver(tableView, name: Notifications.RoomLogDidChange, object: room!)
        }
        
        guard let newRoom = room as? Room else {
            // Remove the details button and title
            title = nil
            navigationItem.rightBarButtonItems = nil
            return
        }
        
        title = newRoom.name
        navigationItem.prompt = newRoom.server!.host
        
        self.room = newRoom
        
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.RoomLogDidChange, object: room!)
        
        // Don't show the option to compose a message if we are not in the room
        updateButtons()
        
        tableView.reloadData()
    }
    
    func showRoomInfo() {
        let roomInfoViewController = RoomInfoTableViewController(room!)
        show(roomInfoViewController, sender: nil)
    }
    
    func showMessageComposer() {
        let composer = MessageComposer()
        composer.room = room!
        let nav = UINavigationController(rootViewController: composer)
        modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if room != nil {
            return 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room!.log.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let logEvent = room!.log[indexPath.row]
        
        
        if logEvent is UserLogEvent {
            let regularCell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let userLogEvent = logEvent as! UserLogEvent
            
            var suffix = ""
            
            switch userLogEvent.self {
            case is UserJoinLogEvent:
                suffix = NSLocalizedString("JOINED_THE_ROOM", comment: "")
            case is UserPartLogEvent:
                suffix = NSLocalizedString("LEFT_THE_ROOM", comment: "")
            case is UserQuitLogEvent:
                suffix = NSLocalizedString("QUIT", comment: "")
            default:
                break
            }
            
            let coloredName = userLogEvent.sender.coloredName(for: room!)
            let attributedString = NSMutableAttributedString(attributedString: coloredName)
            // Spacer
            attributedString.append(NSAttributedString(string: " "))
            attributedString.append(NSAttributedString(string: suffix))
            regularCell.textLabel!.attributedText = attributedString
            
            return regularCell
            
        } else if logEvent is MessageLogEvent {
            let cell = TextViewCell()
            
            // Make the text stationary
            cell.textView.isSelectable = false
            cell.textView.isScrollEnabled = false
            
            let messageLogEvent = logEvent as! MessageLogEvent
            cell.textView.text = messageLogEvent.contents
            cell.label.attributedText = messageLogEvent.sender.coloredName(for: room!)
            
            return cell
            
        } else {
            print("Unknown log event, could not be rendered")
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let event = room!.log[indexPath.row]
        
        if let msgEvent = event as? MessageLogEvent {
            return TextViewCell.getHeight(msgEvent.contents, width: tableView.frame.width - 32)
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
}
