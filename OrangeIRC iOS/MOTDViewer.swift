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
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = navigationController as! MOTDNavigationController
        
        textView.isEditable = false
        textView.text = nav.server!.motd
        
        navigationItem.prompt = nav.server!.host
        navigationItem.title = NSLocalizedString("MOTD", comment: "Message of the Day")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    func done() {
        dismiss(animated: true, completion: nil)
    }
    
}
