//
//  AddServerViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import UIKit
import OrangeIRCCore

let CELL_IDENTIFIER = "TextFieldCell"

let REQUIRED = NSLocalizedString("REQUIRED", comment: "Required")
let OPTIONAL = NSLocalizedString("OPTIONAL", comment: "Optional")

class AddServerViewController : UITableViewController {
    
    var hostCell: TextFieldCell?
    var portCell: TextFieldCell?
    var nicknameCell: TextFieldCell?
    var usernameCell: TextFieldCell?
    var realnameCell: TextFieldCell?
    var passwordCell: TextFieldCell?
    //var autoJoinCell: SwitchCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.title! = NSLocalizedString("ADD_SERVER", comment: "Add Server")
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
        var tempCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER)
        if tempCell == nil {
            tempCell = TextFieldCell(style: UITableViewCellStyle.default, reuseIdentifier: CELL_IDENTIFIER)
        }
        
        let textFieldCell = tempCell as? TextFieldCell
        textFieldCell?.textField.autocorrectionType = .no
        textFieldCell?.textField.autocapitalizationType = .none
        
        //let switchCell = tempCell as? SwitchCell
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                textFieldCell!.label.text = NSLocalizedString("HOSTNAME", comment: "Hostname")
                textFieldCell!.textField.placeholder = NSLocalizedString("IRC_DOT_EXAMPLE_DOT_COM", comment: "irc.example.com")
                self.hostCell = textFieldCell!
            case 1:
                textFieldCell!.label.text = NSLocalizedString("PORT", comment: "Port")
                textFieldCell!.textField.placeholder = "6667"
                textFieldCell!.textField.keyboardType = .numberPad
                self.portCell = textFieldCell!
            case 2:
                textFieldCell!.label.text = NSLocalizedString("PASSWORD", comment: "Password")
                textFieldCell!.textField.placeholder = OPTIONAL
                textFieldCell!.textField.isSecureTextEntry = true
                self.passwordCell = textFieldCell!
            case 3:
                break
                //self.autoJoinCell = switchCell!
                //switchCell!.label.text = NSLocalizedString("AUTOMATICALLY_JOIN", comment: "Automatically Join")
            default:
                break
            }
        case 1:
            switch  indexPath.row {
            case 0:
                textFieldCell?.label.text = NSLocalizedString("NICKNAME", comment: "Nickname")
                textFieldCell?.textField.placeholder = REQUIRED
                self.nicknameCell = textFieldCell
            case 1:
                textFieldCell?.label.text = NSLocalizedString("USERNAME", comment: "Username")
                textFieldCell?.textField.placeholder = REQUIRED
                self.usernameCell = textFieldCell
            case 2:
                textFieldCell?.label.text = NSLocalizedString("REAL_NAME", comment: "Real Name")
                textFieldCell?.textField.placeholder = REQUIRED
                textFieldCell?.textField.autocapitalizationType = .words
                self.realnameCell = textFieldCell
            default:
                break
            }
        default:
            break
        }
        return tempCell!
    }
    
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        // TODO: Implement sanity checks
        _ = self.appDelegate.addServer(host: (self.hostCell?.textField.text)!, port: Int((self.portCell?.textField.text)!)!, nickname: (self.nicknameCell?.textField.text)!, username: (self.usernameCell?.textField.text)!, realname: (self.realnameCell?.textField.text)!, password: (self.passwordCell?.textField.text)!)
        //server.autoJoin = self.autoJoinCell!.switch.isOn
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
