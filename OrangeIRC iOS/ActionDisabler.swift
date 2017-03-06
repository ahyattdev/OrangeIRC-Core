//
//  ActionDisabler.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/5/17.
//
//

import UIKit

class ActionDisabler: NSObject, UITextFieldDelegate {
    
    let action: UIAlertAction
    
    let textField: UITextField
    init(action: UIAlertAction, textField: UITextField) {
        self.action = action
        self.textField = textField
        super.init()
        textField.delegate = self
        
        // Initialize it as enabled or disabled
        if let text = textField.text {
            action.isEnabled = !text.isEmpty
        } else {
            action.isEnabled = false
        }

    }
    
    deinit {
        print("Too early?")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            action.isEnabled = text.utf8.count - string.utf8.count > 0
        } else {
            action.isEnabled = false
        }
        
        return true
    }
    
}
