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
    
    var deallocationPreventer: ActionDisabler?
    
    init(action: UIAlertAction, textField: UITextField) {
        self.action = action
        
        super.init()
        
        self.deallocationPreventer = self
        textField.delegate = self
        
        // Initialize it as enabled or disabled
        if let text = textField.text {
            action.isEnabled = !text.isEmpty
        } else {
            action.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Ugly Foundation code
        var newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
        
        // UITextFields silently get rid of \n
        newString = newString.replacingOccurrences(of: "\n", with: "")
        
        action.isEnabled = !newString.isEmpty
        
        return true
    }
}
