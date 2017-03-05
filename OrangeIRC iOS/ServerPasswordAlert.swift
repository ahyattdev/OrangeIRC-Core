//
//  ServerPasswordAlert.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/4/17.
//
//

import UIKit
import OrangeIRCCore

class ServerPasswordAlert : UIAlertController, UITextFieldDelegate {
    
    let server: Server
    
    var authenticate: UIAlertAction!, disconnect: UIAlertAction!
    var passwordField: UITextField!
    
    // No property is get-only if you try hard enough
    override var preferredStyle: UIAlertControllerStyle {
        return .alert
    }
    
    init(_ server: Server) {
        self.server = server
        super.init(nibName: nil, bundle: nil)
        
        title = localized("SERVER_PASSWORD_NEEDED")
        message = localized("SERVER_PASSWORD_NEEDED_DESCRIPTION").replacingOccurrences(of: "@SERVER@", with: server.displayName)
        
        disconnect = UIAlertAction(title: localized("DISCONNECT"), style: .destructive, handler: { a in
            self.server.disconnect()
        })
        addAction(disconnect)
        
        authenticate = UIAlertAction(title: localized("AUTHENTICATE"), style: .default, handler: { a in
            if let text = self.passwordField.text {
                self.server.password = text
                self.server.sendPassword()
            }
        })
        authenticate.isEnabled = false
        addAction(authenticate)
        
        addTextField(configurationHandler: { (textField) in
            self.passwordField = textField
            
            self.passwordField.isSecureTextEntry = true
            self.passwordField.delegate = self
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            // Let it be used as a password if it isn't empty
            authenticate.isEnabled = text.utf8.count - string.utf8.count > 0
        } else {
            authenticate.isEnabled = false
        }
        
        return true
    }
    
}
