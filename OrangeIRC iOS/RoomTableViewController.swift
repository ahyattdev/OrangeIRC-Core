//
//  RoomViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import UIKit
import OrangeIRCCore

class RoomTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let room: Room
    
    let detailButton = UIBarButtonItem(title: localized("DETAILS"), style: .plain, target: nil, action: #selector(showRoomInfo))
    
    let toolbar: RoomToolbar
    
    let textView: UITextView
    
    let tableView: UITableView
    
    init(_ room: Room) {
        self.room = room
        
        toolbar = RoomToolbar(room: room)
        
        textView = UITextView()
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        
        super.init(nibName: nil, bundle: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        // Can't use self before super.init, thanks Swift!
        detailButton.target = self
        
        view.addSubview(tableView)
        view.addSubview(toolbar)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = detailButton
        
        updateButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(roomDataChanged(_:)), name: Notifications.RoomStateUpdated, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLog), name: Notifications.NewLogEventForRoom, object: room)
        
        title = room.displayName
        navigationItem.prompt = room.server!.displayName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolbar.updateConstraints()
        toolbar.becomeFirstResponder()
    }
    
    override func updateViewConstraints() {
        // tableView
        super.updateViewConstraints()
        
        let top = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
        let trailing = NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        view.addConstraints([top, bottom, leading, trailing])
    }
    
    func roomDataChanged(_ notification: NSNotification) {
        updateButtons()
    }
    
    func updateButtons() {
        // Only enable the composer button when a message can be sent
        //composerButton.isEnabled = room.canSendMessage
        detailButton.isEnabled = true
    }
    
    func reloadLog() {
        // New messages are on the log, reload display
        tableView.reloadData()
        // Scroll to bottom
        tableView.scrollToRow(at: IndexPath(row: room.log.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    func showRoomInfo() {
        let roomInfoViewController = RoomInfoTableViewController(room)
        show(roomInfoViewController, sender: nil)
    }
    
    func showMessageComposer() {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room.log.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let logEvent = room.log[indexPath.row]
        let cell = LogEventCell(logEvent: logEvent, reuseIdentifier: nil)
        return cell
//        let logEvent = room.log[indexPath.row]
//        
//        
//        if logEvent is UserLogEvent {
//            let regularCell = UITableViewCell(style: .default, reuseIdentifier: nil)
//            let userLogEvent = logEvent as! UserLogEvent
//            
//            var suffix = ""
//            
//            switch userLogEvent.self {
//            case is UserJoinLogEvent:
//                suffix = localized("JOINED_THE_ROOM")
//            case is UserPartLogEvent:
//                suffix = localized("LEFT_THE_ROOM")
//            case is UserQuitLogEvent:
//                suffix = localized("QUIT")
//            default:
//                print("Unknown UserLogEvent, no caption found")
//                break
//            }
//            
//            let coloredName = userLogEvent.sender.coloredName(for: room)
//            let attributedString = NSMutableAttributedString(attributedString: coloredName)
//            // Spacer
//            attributedString.append(NSAttributedString(string: " "))
//            attributedString.append(NSAttributedString(string: suffix))
//            regularCell.textLabel!.attributedText = attributedString
//            
//            return regularCell
//            
//        } else if let msgEvent = logEvent as? MessageLogEvent {
//            let msgCell = MessageCell(message: msgEvent, room: room, showLabel: true)
//            msgCell.delegate = self
//            return msgCell
//            
//        } else {
//            print("Unknown log event, could not be rendered")
//            return UITableViewCell()
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let event = room.log[indexPath.row]
        
        return event is MessageLogEvent
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let event = room.log[indexPath.row]
        
        if event is MessageLogEvent {
            return action == #selector(copy(_:))
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if let msgEvent = room.log[indexPath.row] as? MessageLogEvent {
            
            switch action {
                
            case #selector(copy(_:)):
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = msgEvent.contents
                
            default:
                break
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let event = room.log[indexPath.row]
        
        return event is MessageLogEvent
    }
    
}
