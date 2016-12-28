//
//  MessageComposer.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/4/16.
//
//

import UIKit
import OrangeIRCCore

class ComposerViewController : UIViewController {
    
    let room: Room
    
    var initialText: String?
    
    var textView = UITextView()
    
    init(_ room: Room) {
        self.room = room
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(_ room: Room, initialText: String) {
        self.init(room)
        
        self.initialText = initialText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        title = room.name
        navigationItem.prompt = room.server!.host
        
        view = textView
        
        if let initialText = initialText {
            textView.text = initialText
        }
        
        // Show the keyboard
        textView.becomeFirstResponder()
        
        // Close this when the escape key is pressed
        addKeyCommand(UIKeyCommand(input: UIKeyInputEscape, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(cancel), discoverabilityTitle: NSLocalizedString("CANCEL", comment: "")))
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func done() {
        room.send(message: textView.text)
        dismiss(animated: true, completion: nil)
    }
    
}
