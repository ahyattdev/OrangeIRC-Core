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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tempCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER)
        if tempCell == nil {
            tempCell = TextFieldCell(style: UITableViewCellStyle.default, reuseIdentifier: CELL_IDENTIFIER)
        }
        
        let cell = tempCell as! TextFieldCell
        cell.textField.autocorrectionType = .no
        cell.textField.autocapitalizationType = .none
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.label.text = NSLocalizedString("HOSTNAME", comment: "Hostname")
                cell.textField.placeholder = NSLocalizedString("IRC_DOT_EXAMPLE_DOT_COM", comment: "irc.example.com")
                self.hostCell = cell
            case 1:
                cell.label.text = NSLocalizedString("PORT", comment: "Port")
                cell.textField.placeholder = "6667"
                cell.textField.keyboardType = .numberPad
                self.portCell = cell
            default:
                break
            }
        case 1:
            switch  indexPath.row {
            case 0:
                cell.label.text = NSLocalizedString("NICKNAME", comment: "Nickname")
                cell.textField.placeholder = REQUIRED
                self.nicknameCell = cell
            case 1:
                cell.label.text = NSLocalizedString("USERNAME", comment: "Username")
                cell.textField.placeholder = REQUIRED
                self.usernameCell = cell
            case 2:
                cell.label.text = NSLocalizedString("REAL_NAME", comment: "Real Name")
                cell.textField.placeholder = REQUIRED
                cell.textField.autocapitalizationType = .words
                self.realnameCell = cell
            case 3:
                cell.label.text = NSLocalizedString("PASSWORD", comment: "Password")
                cell.textField.placeholder = OPTIONAL
                cell.textField.isSecureTextEntry = true
                self.passwordCell = cell
            default:
                break
            }
        default:
            break
        }
        return cell
    }
    
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        // TODO: Implement sanity checks
        self.appDelegate.addServer(host: (self.hostCell?.textField.text)!, port: Int((self.portCell?.textField.text)!)!, nickname: (self.nicknameCell?.textField.text)!, username: (self.usernameCell?.textField.text)!, realname: (self.realnameCell?.textField.text)!, password: (self.passwordCell?.textField.text)!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
