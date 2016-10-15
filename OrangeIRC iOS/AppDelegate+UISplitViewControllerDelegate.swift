//
//  AppDelegate+UISplitViewControllerDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 10/14/16.
//
//

import UIKit

extension AppDelegate {
    
    @objc(splitViewController:collapseSecondaryViewController:ontoPrimaryViewController:) func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}
