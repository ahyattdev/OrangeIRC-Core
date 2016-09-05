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
    
    struct Segues {
        
        private init() { }
        
        static let ShowInfo = "ShowInfo"
        static let ShowComposer = "ShowComposer"
        
    }
    
    struct CellIdentifiers {
        
        private init() { }
        
        static let Cell = "Cell"
    }
    
    var room: Room?
    
    var composerButton: UIBarButtonItem {
        get {
            return UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composerButtonTapped))
        }
        
    }
    
    var optionsButton: UIBarButtonItem {
        get {
            return UIBarButtonItem(title: NSLocalizedString("DETAILS", comment: "Details"), style: .plain, target: self, action: #selector(optionsButtonTapped))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: Notifications.DisplayedRoomDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if room != nil {
            navigationItem.rightBarButtonItems = room!.isJoined ? [optionsButton, composerButton] : [optionsButton]
        }
    }
    
    func handle(_ notification: NSNotification) {
        switch notification.name {
        case Notifications.DisplayedRoomDidChange:
            updateWith(room: notification.object)
        default: break
        }
    }
    
    func updateWith(room: Any?) {
        // Only run this on iPad
        if !appDelegate.splitView!.isCollapsed && navigationController!.visibleViewController != self{
            navigationController!.popToViewController(self, animated: true)
        }
        
        if self.room != nil {
            // Stop observing the old room
            NotificationCenter.default.removeObserver(tableView, name: Notifications.RoomLogDidChange, object: room!)
        }
        
        guard let newRoom = room as? Room else {
            // Remove the details button and title
            navigationItem.title = nil
            navigationItem.rightBarButtonItems = nil
            return
        }
        
        // Don't show the option to compose a message if we are not in the room
        navigationItem.rightBarButtonItems = newRoom.isJoined ? [optionsButton, composerButton] : [optionsButton]
        
        navigationItem.title = newRoom.name
        
        self.room = newRoom
        
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.RoomLogDidChange, object: room!)
        
        tableView.reloadData()
    }
    
    func optionsButtonTapped() {
        self.performSegue(withIdentifier: Segues.ShowInfo, sender: self.room!)
    }
    
    func composerButtonTapped() {
        self.performSegue(withIdentifier: Segues.ShowComposer, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Segues.ShowInfo:
            let info = segue.destination as! RoomInfo
            info.room = room
        case Segues.ShowComposer:
            let nav = segue.destination as! ComposerNavigationController
            nav.room = room
        default:
            break
        }
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifiers.Cell)
        
        let logEvent = room!.log[indexPath.row]
        let userLogEvent = logEvent as? UserLogEvent
        let messageLogEvent = logEvent as? MessageLogEvent
        switch logEvent.self {
            
        case is UserJoinLogEvent:
            cell.textLabel!.text = "\(userLogEvent!.sender) \(NSLocalizedString("JOINED_THE_ROOM", comment: "When someone joins the room"))"
            
        case is UserPartLogEvent:
            cell.textLabel!.text = "\(userLogEvent!.sender) \(NSLocalizedString("LEFT_THE_ROOM", comment: "When someone joins the room"))"
            
        case is UserQuitLogEvent:
            cell.textLabel!.text = "\(userLogEvent!.sender) \(NSLocalizedString("QUIT", comment: "When someone quits"))"
            
        case is MessageLogEvent:
            cell.textLabel!.text = messageLogEvent!.contents
            cell.detailTextLabel!.text = messageLogEvent!.sender.name
            cell.detailTextLabel!.textColor = appDelegate.color(for: messageLogEvent!.sender, in: room!)
        
        default:
            break
        }
        
        return cell
    }
    
}
