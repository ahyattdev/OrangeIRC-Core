//
//  UIResponder+Localized.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 2/25/17.
//
//

import UIKit

extension UIResponder {
    
    func localized(_ string: String) -> String {
        return NSLocalizedString(string, comment: "")
    }
    
}
