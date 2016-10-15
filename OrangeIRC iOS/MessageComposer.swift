//
//  MessageComposer.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/4/16.
//
//

import UIKit
import OrangeIRCCore

class MessageComposer : UIViewController {
    
    var room: Room?
    
    var textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        navigationItem.title = room!.name
        navigationItem.prompt = room!.server!.host
        
        view = textView
        
        // Show the keyboard
        textView.becomeFirstResponder()
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func done() {
        room!.send(message: textView.text)
        dismiss(animated: true, completion: nil)
    }
    
}
