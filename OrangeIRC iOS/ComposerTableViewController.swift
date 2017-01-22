//
//  ComposerTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/28/16.
//
//

import UIKit
import OrangeIRCCore

class ComposerTableViewController : UITableViewController, UITextViewDelegate {
    
    enum Mode {
        
        case Composer
        case ReplyToSender
        case ReplyToRecipient
        
    }
    
    var message: MessageLogEvent?
    let room: Room
    let mode: Mode
    
    var otherUser: User? {
        if mode == .ReplyToSender {
            return message!.sender
        } else {
            return message!.replyTo!
        }
        
    }
    
    var composedMessage = ""
    var composerCell: TextViewCell?
    
    var destinationPicker: UISegmentedControl?
    
    init(room: Room, mode: Mode) {
        self.room = room
        self.mode = mode
        
        super.init(style: .grouped)
    }
    
    convenience init(message: MessageLogEvent, room: Room, mode: Mode) {
        self.init(room: room, mode: mode)
        self.message = message
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("SEND", comment: ""), style: .done, target: self, action: #selector(send))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        addKeyCommand(UIKeyCommand(input: UIKeyInputEscape, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(cancel), discoverabilityTitle: NSLocalizedString("CANCEL", comment: "")))
        
        if mode == .Composer {
            title = NSLocalizedString("NEW_MESSAGE", comment: "")
            navigationItem.prompt = room.name
        } else {
            title = NSLocalizedString("REPLY", comment: "")
            navigationItem.prompt = "\(NSLocalizedString("TO_UPPERCASE", comment: "")) \(otherUser!.nick) \(NSLocalizedString("ON", comment: "")) \(room.name)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        composerCell!.textView.becomeFirstResponder()
    }
    
    func send() {
        if mode == .Composer {
            room.send(message: composedMessage)
        } else {
            // There is a destination picker
            // FIXME: Magic numbers
            if destinationPicker!.selectedSegmentIndex == 0 {
                // Send on channel
                room.send(message: "\(otherUser!.nick): \(composedMessage)")
            } else {
                // Send as private message
                room.server!.startPrivateMessageSession(otherUser!.nick, with: composedMessage)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        
        composedMessage = composerCell!.textView.text
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if mode == .Composer {
            // Just editable text view
            return 1
        } else {
            // Original message and text view
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && mode != .Composer {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if mode != .Composer && indexPath.section == 0 {
            // Show original message
            return MessageCell(message: message!, room: room, showLabel: true)
            
        } else if mode != .Composer && indexPath.section == 1 && indexPath.row == 0 {
            // Show destination picker
            let onChannel = NSLocalizedString("ON_CHANNEL", comment: "")
            let privateMessage = NSLocalizedString("BY_PRIVATE_MESSAGE", comment: "")
            let segmentCell = SegmentedControlCell(segments: [onChannel, privateMessage], target: nil, action: nil)
            segmentCell.segmentedControl.selectedSegmentIndex = 0
            self.destinationPicker = segmentCell.segmentedControl
            
            return segmentCell
            
        } else {
            // Show composer
            let composerCell = TextViewCell(showLabel: false)
            composerCell.textView.isEditable = true
            composerCell.textView.dataDetectorTypes = []
            composerCell.textView.delegate = self
            
            self.composerCell = composerCell
            
            return composerCell
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return mode != .Composer && indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:)) && mode != .Composer && indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:))  {
            UIPasteboard.general.string = message!.contents
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 && mode != .Composer {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        if indexPath.section == 0 && mode != .Composer {
            return TextViewCell.getHeight(message!.contents, width: tableView.frame.width - 32, showLabel: true)
        } else {
            let height = TextViewCell.getHeight(composedMessage, width: tableView.frame.width - 32, showLabel: false)
            return height
        }
    }
    
}
