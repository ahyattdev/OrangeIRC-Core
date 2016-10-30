//
//  AddServerViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import UIKit
import OrangeIRCCore

class AddServerViewController : UITableViewController {
    
    static let REQUIRED = NSLocalizedString("REQUIRED", comment: "Required")
    static let OPTIONAL = NSLocalizedString("OPTIONAL", comment: "Optional")
    
    var hostCell: TextFieldCell?
    var portCell: TextFieldCell?
    var nicknameCell: TextFieldCell?
    var usernameCell: TextFieldCell?
    var realnameCell: TextFieldCell?
    var passwordCell: TextFieldCell?
    var autoJoinCell: SwitchCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("ADD_SERVER", comment: "Add Server")
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButton))
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButton))
        navigationItem.rightBarButtonItem = doneButton
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
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                textFieldCell.textLabel!.text = NSLocalizedString("HOSTNAME", comment: "Hostname")
                textFieldCell.textField.placeholder = NSLocalizedString("IRC_DOT_EXAMPLE_DOT_COM", comment: "irc.example.com")
                textFieldCell.textField.keyboardType = .URL
                self.hostCell = textFieldCell
                hostCell!.tag = 0
            case 1:
                textFieldCell.textLabel!.text = NSLocalizedString("PORT", comment: "Port")
                textFieldCell.textField.placeholder = "6667"
                textFieldCell.textField.keyboardType = .numberPad
                self.portCell = textFieldCell
                portCell!.tag = 1
            case 2:
                textFieldCell.textLabel!.text = NSLocalizedString("PASSWORD", comment: "Password")
                textFieldCell.textField.placeholder = AddServerViewController.OPTIONAL
                textFieldCell.textField.isSecureTextEntry = true
                self.passwordCell = textFieldCell
                passwordCell!.tag = 2
            case 3:
                self.autoJoinCell = switchCell
                switchCell.textLabel!.text = NSLocalizedString("AUTOMATICALLY_JOIN", comment: "Automatically Join")
                return switchCell
            default:
                break
            }
        case 1:
            switch  indexPath.row {
            case 0:
                textFieldCell.textLabel!.text = NSLocalizedString("NICKNAME", comment: "Nickname")
                textFieldCell.textField.placeholder = AddServerViewController.REQUIRED
                self.nicknameCell = textFieldCell
                nicknameCell!.tag = 3
            case 1:
                textFieldCell.textLabel!.text = NSLocalizedString("USERNAME", comment: "Username")
                textFieldCell.textField.placeholder = AddServerViewController.REQUIRED
                self.usernameCell = textFieldCell
                usernameCell!.tag = 4
            case 2:
                textFieldCell.textLabel!.text = NSLocalizedString("REAL_NAME", comment: "Real Name")
                textFieldCell.textField.placeholder = AddServerViewController.REQUIRED
                textFieldCell.textField.autocapitalizationType = .words
                self.realnameCell = textFieldCell
                realnameCell!.tag = 5
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
        dismiss(animated: true, completion: nil)
    }
    
    func doneButton() {
        // TODO: Implement sanity checks
        
        let server = appDelegate.addServer(host: (hostCell?.textField.text)!, port: Int((portCell?.textField.text)!)!, nickname: (nicknameCell?.textField.text)!, username: (usernameCell?.textField.text)!, realname: (realnameCell?.textField.text)!, password: (passwordCell?.textField.text)!)
        server.autoJoin = autoJoinCell!.switch.isOn
        
        dismiss(animated: true, completion: nil)
    }
    
}
