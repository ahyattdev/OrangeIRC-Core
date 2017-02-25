//
//  ChannelListTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 2/25/17.
//
//

import UIKit
import OrangeIRCCore

class ChannelListTableViewController : UITableViewController {
    
    let server: Server
    
    init(_ server: Server) {
        self.server = server
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = localized("CHANNELS")
        updatePrompt()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        navigationItem.leftBarButtonItem!.isEnabled = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        NotificationCenter.default.addObserver(tableView, selector: #selector(tableView.reloadData), name: Notifications.ListUpdatedForServer, object: server)
        NotificationCenter.default.addObserver(self, selector: #selector(finished), name: Notifications.ListFinishedForServer, object: server)
        
        server.fetchChannelList()
    }
    
    func refresh() {
        navigationItem.leftBarButtonItem!.isEnabled = false
        server.fetchChannelList()
        tableView.reloadData()
    }
    
    func finished() {
        navigationItem.leftBarButtonItem!.isEnabled = true
    }
    
    func done() {
        dismiss(animated: true, completion: nil)
    }
    
    func updatePrompt() {
        navigationItem.prompt = "\(localized("CHANNELS_ON")) \(server.displayName)"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return server.channelListCache.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RightDetailTextViewCell(nil)
        let channelData = server.channelListCache[indexPath.row]
        
        cell.title.text = channelData.name
        
        // Plurals
        var usersWord: String!
        if channelData.users == 1 {
            usersWord = localized("USER")
        } else {
            usersWord = localized("USERS")
        }
        cell.detail.text = "\(channelData.users) \(usersWord)"
        
        cell.textView.text = channelData.topic
        
        return cell
    }
    
}
