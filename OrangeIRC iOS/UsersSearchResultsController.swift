//
//  UsersSearchResultsTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/28/16.
//
//

import UIKit
import OrangeIRCCore

class UsersSearchResultsController : UITableViewController, UISearchResultsUpdating {
    
    let room: Channel
    
    var filteredUsers = [User]()
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var nav: UINavigationController
    
    init(_ room: Channel, navigationController: UINavigationController) {
        self.room = room
        nav = navigationController
        
        super.init(style: .plain)
        
        // Because we can't pass in self before we call super.init
        // But we can't call super.init without initializing searchController
        // Big problem with Swift
        searchController = UISearchController(searchResultsController: self)
        searchController.searchResultsUpdater = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.isEmpty {
            filteredUsers.removeAll()
        } else {
            filteredUsers = room.users.filter {
                $0.nick.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        // The users list
        let user = filteredUsers[indexPath.row]
        cell.textLabel!.text = user.nick
        
        cell.textLabel!.textColor = user.color(room: room)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]
        let userInfo = UserInfoTableViewController(user: user, server: room.server!)
        searchController.dismiss(animated: true, completion: nil)
        searchController.searchBar.text = nil
        nav.pushViewController(userInfo, animated: true)
    }
    
}
