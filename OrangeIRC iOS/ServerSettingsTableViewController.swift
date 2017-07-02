//
//  AddServerViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import UIKit
import OrangeIRCCore

class ServerSettingsTableViewController : UITableViewController, UITextFieldDelegate {
    
    enum Mode {
        
        case Add
        case Edit
        
    }
    
    let REQUIRED = localized("REQUIRED")
    let OPTIONAL = localized("OPTIONAL")
    
    var hostCell: TextFieldCell?
    var portCell: TextFieldCell?
    var nicknameCell: TextFieldCell?
    var usernameCell: TextFieldCell?
    var realnameCell: TextFieldCell?
    var passwordCell: TextFieldCell?
    var autoJoinCell: SwitchCell?
    
    // Determines whether this will edit a server
    var mode: Mode = .Add
    
    // The server to be used if editing
    var server: Server?
    
    // Used for putting this VC in edit mode
    init(style: UITableViewStyle, edit server: Server) {
        super.init(style: style)
        self.mode = .Edit
        self.server = server
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("stub")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mode == .Add {
            title = localized("ADD_SERVER")
        } else {
            title = localized("EDIT_SERVER")
        }
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButton))
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButton))
        navigationItem.rightBarButtonItem = doneButton
        
        // Close this when the escape key is pressed
        addKeyCommand(UIKeyCommand(input: UIKeyInputEscape, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(self.cancelButton), discoverabilityTitle: localized("CANCEL")))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hostCell!.textField.becomeFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textFieldCell = TextFieldCell()
        let switchCell = SwitchCell()
        
        textFieldCell.textField.autocorrectionType = .no
        textFieldCell.textField.autocapitalizationType = .none
        textFieldCell.textField.returnKeyType = .next
        textFieldCell.textField.delegate = self
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                textFieldCell.textLabel!.text = localized("HOSTNAME")
                textFieldCell.textField.placeholder = localized("IRC_DOT_EXAMPLE_DOT_COM")
                textFieldCell.textField.keyboardType = .URL
                self.hostCell = textFieldCell
                
                if mode == .Edit {
                    hostCell!.textField.text = server!.host
                }
                
            case 1:
                textFieldCell.textLabel!.text = localized("PORT")
                textFieldCell.textField.placeholder = "6667"
                textFieldCell.textField.keyboardType = .numberPad
                textFieldCell.textField.tag = 1
                self.portCell = textFieldCell
                
                if mode == .Edit {
                    portCell!.textField.text = String(server!.port)
                }
                
            case 2:
                textFieldCell.textLabel!.text = localized("PASSWORD")
                textFieldCell.textField.placeholder = OPTIONAL
                textFieldCell.textField.isSecureTextEntry = true
                textFieldCell.textField.tag = 2
                self.passwordCell = textFieldCell
                
                if mode == .Edit {
                    passwordCell!.textField.text = server!.password
                }
                
            case 3:
                self.autoJoinCell = switchCell
                switchCell.textLabel!.text = localized("AUTOMATICALLY_JOIN")
                
                if mode == .Edit {
                    autoJoinCell!.switch.isOn = server!.autoJoin
                }
                
                return switchCell
                
            default:
                break
            }
        case 1:
            switch  indexPath.row {
            case 0:
                textFieldCell.textLabel!.text = localized("NICKNAME")
                textFieldCell.textField.placeholder = REQUIRED
                textFieldCell.textField.tag = 3
                self.nicknameCell = textFieldCell
                
                if mode == .Edit {
                    nicknameCell!.textField.text = server!.nickname
                }
                
            case 1:
                textFieldCell.textLabel!.text = localized("USERNAME")
                textFieldCell.textField.placeholder = REQUIRED
                textFieldCell.textField.tag = 4
                self.usernameCell = textFieldCell
                
                if mode == .Edit {
                    usernameCell!.textField.text = server!.username
                }
                
            case 2:
                textFieldCell.textLabel!.text = localized("REAL_NAME")
                textFieldCell.textField.placeholder = REQUIRED
                textFieldCell.textField.autocapitalizationType = .words
                textFieldCell.textField.returnKeyType = .done
                textFieldCell.textField.tag = 5
                self.realnameCell = textFieldCell
                
                if mode == .Edit {
                    realnameCell!.textField.text = server!.realname
                }
                
            default:
                break
                
            }
            
        default:
            break
            
        }
        
        return textFieldCell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func cancelButton() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func showMissingField(_ name: String, textField: UITextField) {
        let message = localized("THE_FIELD_IS_EMPTY").replacingOccurrences(of: "[NAME]", with: name.lowercased())
        let alert = UIAlertController(title: localized("REQUIRED_FIELD_EMPTY"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: { a in
            textField.becomeFirstResponder()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func doneButton() {
        // TODO: Implement sanity checks
        
        switch mode {
            
        case .Add:
            // Make a new server
            guard let host = hostCell?.textField.text, !hostCell!.textField.text!.isEmpty else {
                showMissingField(localized("HOST"), textField: hostCell!.textField)
                return
            }
            guard let port = Int(portCell!.textField.text!), !portCell!.textField.text!.isEmpty else {
                showMissingField(localized("PORT"), textField: portCell!.textField)
                return
            }
            guard let nickname = nicknameCell?.textField.text, !nicknameCell!.textField.text!.isEmpty else {
                showMissingField(localized("NICKNAME"), textField: nicknameCell!.textField)
                return
            }
            guard let username = usernameCell?.textField.text, !usernameCell!.textField.text!.isEmpty else {
                showMissingField(localized("USERNAME"), textField: usernameCell!.textField)
                return
            }
            guard let realname = realnameCell?.textField.text, !realnameCell!.textField.text!.isEmpty else {
                showMissingField(localized("REALNAME"), textField: realnameCell!.textField)
                return
            }
            guard let password = passwordCell?.textField.text else {
                return
            }
            
            let server = ServerManager.shared.addServer(host: host, port: port, nickname: nickname, username: username, realname: realname, password: password)
            
            server.autoJoin = autoJoinCell!.switch.isOn
            
            view.endEditing(true)
            dismiss(animated: true, completion: nil)
            
        case .Edit:
            // Change an existing server
            // Reassign every setting
            
            // This boolean will be whether or not a setting was changed
            let shouldDisplayReconnectPrompt = (server!.host != hostCell!.textField.text! ||
                server!.port != Int(portCell!.textField.text!)! ||
                server!.nickname != nicknameCell!.textField.text! ||
                server!.username != usernameCell!.textField.text! ||
                server!.realname != realnameCell!.textField.text! ||
                server!.password != passwordCell!.textField.text! ||
                server!.autoJoin != autoJoinCell!.switch.isOn)
                && (server!.isConnectingOrRegistering
                || server!.isConnected)
            
            server!.host = hostCell!.textField.text!
            server!.port = Int(portCell!.textField.text!)!
            server!.preferredNickname = nicknameCell!.textField.text!
            server!.username = usernameCell!.textField.text!
            server!.realname = realnameCell!.textField.text!
            server!.password = passwordCell!.textField.text!
            server!.autoJoin = autoJoinCell!.switch.isOn
            
            // We should save data here
            ServerManager.shared.saveData()
            
            if shouldDisplayReconnectPrompt {
                // Prompt the user to reconnect
                let title = localized("SETTINGS_CHANGED")
                let message = localized("DO_YOU_WANT_TO_RECONNECT")
                let reconnectPrompt = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let reconnectTitle = localized("RECONNECT")
                let reconnect = UIAlertAction(title: reconnectTitle, style: .default, handler: { a in
                    self.server!.reconnect()
                    self.dismiss(animated: true, completion: nil)
                })
                reconnectPrompt.addAction(reconnect)
                
                let dontReconnectTitle = localized("DONT_RECONNECT")
                let dontReconnect = UIAlertAction(title: dontReconnectTitle, style: .cancel, handler: { a in
                    self.dismiss(animated: true, completion: nil)
                })
                reconnectPrompt.addAction(dontReconnect)
                
                present(reconnectPrompt, animated: true, completion: nil)
            } else {
                view.endEditing(true)
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 5 {
            // Done
            doneButton()
        } else {
            // Next
            if let nextField = view.viewWithTag(textField.tag + 1) {
                nextField.becomeFirstResponder()
            }
        }
        return false
    }
    
}
