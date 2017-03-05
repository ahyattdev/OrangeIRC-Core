//
//  NetworkHeaderView.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/5/17.
//
//

import UIKit
import OrangeIRCCore

class NetworkHeaderView: UIView {
    
    var server: Server! = nil

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    static func loadFromNib(server: Server) -> NetworkHeaderView {
        let networkHeaderView = Bundle.main.loadNibNamed(String(describing: NetworkHeaderView.self), owner: self, options: nil)!.first as! NetworkHeaderView
        networkHeaderView.server = server
        
        networkHeaderView.label.text = server.displayName
        
        return networkHeaderView
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let actionSheet = ServerOptionsActionSheet(server: server, sourceView: sender)
        AppDelegate.splitView.present(actionSheet, animated: true, completion: nil)
    }
    
}
