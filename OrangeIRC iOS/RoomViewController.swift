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
        
        private init() {
            
        }
        
        static let ShowInfo = "ShowInfo"
        
    }
    
    var room: Room?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: Notifications.DisplayedRoomDidChange, object: nil)
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
        
        guard let newRoom = room as? Room else {
            // Remove the details button and title
            navigationItem.title = nil
            navigationItem.rightBarButtonItem = nil
            return
        }
        
        let optionsButton = UIBarButtonItem(title: NSLocalizedString("DETAILS", comment: "Details"), style: .plain, target: self, action: #selector(optionsButtonTapped))
        navigationItem.rightBarButtonItem = optionsButton
        
        navigationItem.title = newRoom.name
        
        tableView.reloadData()
        
        self.room = newRoom
    }
    
    func optionsButtonTapped() {
        self.performSegue(withIdentifier: Segues.ShowInfo, sender: self.room!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Segues.ShowInfo:
            let info = segue.destination as! RoomInfo
            info.room = room
        default:
            break
        }
    }
    
}
