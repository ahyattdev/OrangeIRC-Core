//
//  ServersViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import UIKit
import OrangeIRCCore

class ServersTableViewController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateServerDisplay), name: Notifications.ServerStateDidChange, object: nil)
        
        title = NSLocalizedString("SERVERS", comment: "Servers")
        
        let closeButton = UIBarButtonItem(title: NSLocalizedString("CLOSE", comment: ""), style: .plain, target: self, action: #selector(close))
        let addServerButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServer))
        
        navigationItem.leftBarButtonItems = [closeButton, editButtonItem]
        navigationItem.rightBarButtonItem = addServerButton
        
        // Add a shortcut for adding a server
        addKeyCommand(UIKeyCommand(input: "N", modifierFlags: .command, action: #selector(addServer), discoverabilityTitle: NSLocalizedString("ADD_SERVER", comment: "")))
        
        // Close this when the escape key is pressed
        addKeyCommand(UIKeyCommand(input: UIKeyInputEscape, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(close), discoverabilityTitle: NSLocalizedString("CLOSE", comment: "")))
    }
    
    func updateServerDisplay() {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ServerManager.shared.servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let server = ServerManager.shared.servers[indexPath.row]
        
        var cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        cell.textLabel!.text = server.host
        
        if server.isRegistered {
            cell.detailTextLabel?.text = NSLocalizedString("CONNECTED", comment: "Connected")
        } else if server.isConnectingOrRegistering {
            // Add an activity indicator
            cell = ActivityIndicatorCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = server.host
            (cell as! ActivityIndicatorCell).activityIndicator.startAnimating()
        } else {
            cell.detailTextLabel?.text = NSLocalizedString("NOT_CONNECTED", comment: "Not Connected")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let server = ServerManager.shared.servers[indexPath.row]
        let message = NSLocalizedString("SERVER_OPTIONS", comment: "Server options")
        let serverOptions = UIAlertController(title: server.host, message: message, preferredStyle: .actionSheet)
        
        serverOptions.popoverPresentationController?.sourceView = view
        
        // Edits a server's settings
        let settings = UIAlertAction(title: NSLocalizedString("SETTINGS", comment: ""), style: .default, handler: { a in
            let editor = ServerSettingsTableViewController(style: .grouped, edit: server)
            let nav = UINavigationController(rootViewController: editor)
            nav.modalPresentationStyle = .formSheet
            self.present(nav, animated: true, completion: nil)
            
        })
        serverOptions.addAction(settings)
        
        if server.isConnectingOrRegistering || server.isRegistered {
            // Add a disconnect button
            let disconnect = NSLocalizedString("DISCONNECT", comment: "Disconnect")
            let disconnectAction = UIAlertAction(title: disconnect, style: .default, handler: { (action) in
                server.disconnect()
            })
            serverOptions.addAction(disconnectAction)
        } else {
            // Add a connect button
            let connect = NSLocalizedString("CONNECT", comment: "Connect")
            let connectAction = UIAlertAction(title: connect, style: .default, handler: { (action) in
                server.connect()
            })
            serverOptions.addAction(connectAction)
        }
        
        if server.motd != nil {
            // Add a show MOTD button
            let motd = NSLocalizedString("MOTD", comment: "MOTD")
            let motdAction = UIAlertAction(title: motd, style: .default, handler: { (action) in
                self.showMOTD(server: server)
            })
            serverOptions.addAction(motdAction)
        }
        
        let cancel = NSLocalizedString("CANCEL", comment: "Cancel")
        let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        serverOptions.addAction(cancelAction)
        
        present(serverOptions, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let server = ServerManager.shared.servers[indexPath.row]
        
        switch editingStyle {
        case .delete:
            AppDelegate.deleteWithConfirmation(server: server)
        case .insert:
            break
        case .none:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Enables the move row indicators
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Move the Server
        let server = ServerManager.shared.servers.remove(at: sourceIndexPath.row)
        ServerManager.shared.servers.insert(server, at: destinationIndexPath.row)
        
        // Post a notification and save data
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
        ServerManager.shared.saveData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Enables the delete row button
        return true
    }
    
    func addServer() {
        let addServerViewController = ServerSettingsTableViewController(style: .grouped)
        let nav = UINavigationController(rootViewController: addServerViewController)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func showMOTD(server: Server) {
        let motdViewer = MOTDViewController(server)
        let nav = UINavigationController(rootViewController: motdViewer)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true, completion: nil)
    }
}
