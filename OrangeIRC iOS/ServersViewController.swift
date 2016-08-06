//
//  ServersViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/3/16.
//
//

import UIKit

class ServersViewController : UITableViewController {
    
    let CELL_IDENTIFIER = "Cell"
    let ACTIVITY_CELL_IDENTIFIER = "ActivityCell"
    let ADD_SERVER_SEGUE_IDENTIFIER = "AddServer"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateServerDisplay), name: NSNotification.Name(rawValue: Notifications.ServerStateDidChange), object: nil)
    }
    
    func updateServerDisplay() {
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let server = self.appDelegate.servers[indexPath.row]
        
        var identifier = ""
        if server.isConnectingOrRegistering {
            identifier = ACTIVITY_CELL_IDENTIFIER
        } else {
            identifier = CELL_IDENTIFIER
        }
        
        var tempCell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if tempCell == nil {
            tempCell = TextFieldCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        let cell = tempCell! as UITableViewCell
        
        cell.textLabel?.text = server.host
        
        if server.isRegistered {
            cell.detailTextLabel?.text = NSLocalizedString("CONNECTED", comment: "Connected")
        } else if !server.isConnectingOrRegistering {
            cell.detailTextLabel?.text = NSLocalizedString("NOT_CONNECTED", comment: "Not Connected")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let server = self.appDelegate.servers[indexPath.row]
        let message = NSLocalizedString("SERVER_OPTIONS", comment: "Server options")
        let serverOptions = UIAlertController(title: server.host, message: message, preferredStyle: .actionSheet)
        
        serverOptions.popoverPresentationController?.sourceView = self.view
        
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
        
        if server.finishedReadingMOTD && server.isRegistered {
            // Add a show MOTD button
            let motd = NSLocalizedString("MOTD", comment: "MOTD")
            let motdAction = UIAlertAction(title: motd, style: .default, handler: { (action) in
                // TODO: Implement displaying the MOTD
            })
            serverOptions.addAction(motdAction)
        }
        
        
        self.present(serverOptions, animated: true, completion: {
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
    }
    
    @IBAction func addServerButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: ADD_SERVER_SEGUE_IDENTIFIER, sender: nil)
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
