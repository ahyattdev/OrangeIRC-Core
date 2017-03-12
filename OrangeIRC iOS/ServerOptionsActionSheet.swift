//
//  ServerOptionsActionSheet.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/5/17.
//
//

import UIKit
import OrangeIRCCore

class ServerOptionsActionSheet : UIAlertController {
    
    let server: Server
    
    // No property is get-only if you try hard enough
    override var preferredStyle: UIAlertControllerStyle {
        return .actionSheet
    }
    
    init(server: Server, sourceView: UIView) {
        self.server = server
        super.init(nibName: nil, bundle: nil)
        
        popoverPresentationController?.sourceView = sourceView
        
        // Edits a server's settings
        let settings = UIAlertAction(title: localized("SETTINGS"), style: .default, handler: { a in
            let editor = ServerSettingsTableViewController(style: .grouped, edit: server)
            let nav = UINavigationController(rootViewController: editor)
            nav.modalPresentationStyle = .formSheet
            AppDelegate.splitView.present(nav, animated: true, completion: nil)
            
        })
        addAction(settings)
        
        if server.isConnectingOrRegistering || server.isRegistered {
            // Add a disconnect button
            let disconnect = localized("DISCONNECT")
            let disconnectAction = UIAlertAction(title: disconnect, style: .default, handler: { (action) in
                server.disconnect()
            })
            addAction(disconnectAction)
        } else {
            // Add a connect button
            let connect = localized("CONNECT")
            let connectAction = UIAlertAction(title: connect, style: .default, handler: { (action) in
                server.connect()
            })
            addAction(connectAction)
        }
        
        if server.motd != nil {
            // Add a show MOTD button
            let motd = localized("MOTD")
            let motdAction = UIAlertAction(title: motd, style: .default, handler: { (action) in
                let motdViewer = MOTDViewController(server)
                let nav = UINavigationController(rootViewController: motdViewer)
                nav.modalPresentationStyle = .pageSheet
                AppDelegate.splitView.present(nav, animated: true, completion: nil)
            })
            addAction(motdAction)
        }
        
        if server.isConnected {
            let joinAction = UIAlertAction(title: localized("JOIN_CHANNEL"), style: .default, handler: { a in
                AppDelegate.showAlertGlobally(JoinChannelAlertFactory.make(server: server))
            })
            addAction(joinAction)
            
            let chanlistAction = UIAlertAction(title: localized("CHANNEL_LIST"), style: .default, handler: { (action) in
                let chanlistTVC = ChannelListTableViewController(server)
                AppDelegate.showModalGlobally(chanlistTVC, style: .formSheet)
            })
            addAction(chanlistAction)
        }
        
        let deleteAction = UIAlertAction(title: localized("DELETE"), style: .destructive, handler: { a in
            ServerManager.shared.delete(server: server)
        })
        addAction(deleteAction)
        
        let cancel = localized("CANCEL")
        let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        addAction(cancelAction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
