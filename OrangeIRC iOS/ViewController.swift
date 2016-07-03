//
//  ViewController.swift
//  OrangeIRC iOS
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import UIKit
import OrangeIRCCore

class ViewController: UIViewController, ServerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let server = Server(host: "irc.freenode.net", port: 6667, nickname: "kahsdfasfyfd", username: "kahsdfasfyfd", realname: "kahsdfasfyfd", encoding: String.Encoding.utf8)
        server.delegate = self
        server.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didNotRespond(server: Server) {
        
    }
    
    func stoppedResponding(server: Server) {
        
    }
    
    func connectedSucessfully(server: Server) {
        
    }
    
    func didRegister(server: Server) {
        server.join(channel: "#minecraft")
    }
    
    func recieved(notice: String, server: Server) {
        
    }

}
