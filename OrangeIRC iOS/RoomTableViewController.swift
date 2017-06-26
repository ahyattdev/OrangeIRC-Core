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
    
    var toolbar: RoomToolbar!
    
    var tableView: UITableView!
    
    init(_ room: Room) {
        self.room = room
        
        super.init(nibName: nil, bundle: nil)
        
        // Can't use self before super.init, thanks Swift!
        detailButton.target = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = detailButton
        
        updateButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(roomDataChanged(_:)), name: Notifications.RoomStateUpdated, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLog), name: Notifications.NewLogEventForRoom, object: room)
        
        title = room.displayName
        navigationItem.prompt = room.server!.displayName
    }
    
    override func loadView() {
        super.loadView()
        
        toolbar = RoomToolbar(room: room)
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        
        view.addSubview(tableView)
        view.addSubview(toolbar)
        
        let leading = NSLayoutConstraint(item: toolbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
        
        let trailing = NSLayoutConstraint(item: toolbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        toolbar.bottom = NSLayoutConstraint(item: toolbar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        view.addConstraints([leading, trailing, toolbar.bottom])
        
        let tvTop = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        let tvBottom = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let tvLeading = NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
        let tvTrailing = NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        view.addConstraints([tvTop, tvBottom, tvLeading, tvTrailing])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolbar.updateConstraints()
        toolbar.becomeFirstResponder()
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
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
    
    // https://stackoverflow.com/a/32353069/2892777
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RoomTableViewController.keyboardDidShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RoomTableViewController.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        //let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: , right: 0)
        //tableView.contentInset = contentInsets
        tableView.contentInset.bottom = keyboardSize.height
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset.bottom = toolbar.frame.height
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    
}
