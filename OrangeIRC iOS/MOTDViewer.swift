//
//  MOTDViewer.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/4/16.
//
//

import UIKit
import OrangeIRCCore

class MOTDViewer : UIViewController {
    
    var server: Server?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textView = UITextView()
        
        textView.isEditable = false
        textView.text = server!.motd
        
        view = textView
        
        navigationItem.prompt = server!.host
        navigationItem.title = NSLocalizedString("MOTD", comment: "Message of the Day")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    func done() {
        dismiss(animated: true, completion: nil)
    }
    
}
