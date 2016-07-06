//
//  UIViewController+AppDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import UIKit

extension UIViewController {
    
    var appDelegate: AppDelegate {
        get {
            return UIApplication.shared().delegate as! AppDelegate
        }
    }
    
}
