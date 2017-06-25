//
//  AppDelegate.swift
//  OrangeIRC iOS
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import UIKit
import OrangeIRCCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ServerDelegate, UITextFieldDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    var nickservPasswordField: UITextField?
    var doneAction: UIAlertAction?
    
    // View controllers
    static let splitView = UISplitViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.splitView.delegate = self
        
        AppDelegate.splitView.preferredDisplayMode = .allVisible
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window!.rootViewController = AppDelegate.splitView
        
        window!.tintColor = UIColor.orange
        
        let placeholder = UITableViewController(style: .grouped)
        let label = UILabel()
        label.text = localized("CHOSE_ROOM")
        label.textAlignment = .center
        placeholder.tableView.backgroundView = label
        placeholder.tableView.separatorStyle = .none
        
        AppDelegate.splitView.viewControllers = [
            UINavigationController(rootViewController: NetworksTableViewController()),
            UINavigationController(rootViewController: placeholder)
        ]
        
        ServerManager.shared.serverDelegate = self
        
        window!.makeKeyAndVisible()
        
        return true
    }
    
    @objc(splitViewController:collapseSecondaryViewController:ontoPrimaryViewController:) func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        ServerManager.shared.saveData()
        
        for server in ServerManager.shared.servers {
            server.prepareForBackground()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        ServerManager.shared.saveData()
    }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nickservPasswordField {
            guard let text = textField.text as NSString? else {
                return true
            }
            let finalString = text.replacingCharacters(in: range, with: string)
            
            // Disable the done button if no password is given
            doneAction!.isEnabled = !finalString.isEmpty
        }
        
        return true
    }
    
    // Utility function to avoid:
    // Warning: Attempt to present * on * whose view is not in the window hierarchy!
    static func showAlertGlobally(_ alert: UIAlertController) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert
        alertWindow.rootViewController = vc
        alertWindow.tintColor = UIColor.orange
        alertWindow.makeKeyAndVisible()
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showModalGlobally(_ modal: UIViewController, style: UIModalPresentationStyle) {
        let modalWindow = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        modalWindow.windowLevel = UIWindowLevelNormal
        modalWindow.rootViewController = vc
        modalWindow.tintColor = UIColor.orange
        modalWindow.makeKeyAndVisible()
        let nav = UINavigationController(rootViewController: modal)
        nav.modalPresentationStyle = style
        vc.present(nav, animated: true, completion: nil)
    }
    
    static func deleteWithConfirmation(server: Server) {
        let title = localized("DELETE_SERVER").replacingOccurrences(of: "[SERVER]", with: server.displayName)
        let message = localized("DELETE_SERVER_DESCRIPTION")
        let confirmation = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: localized("CANCEL"), style: .cancel, handler: nil)
        confirmation.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: localized("DELETE"), style: .destructive, handler: { (action) in
            ServerManager.shared.delete(server: server)
        })
        confirmation.addAction(deleteAction)
        
        AppDelegate.showAlertGlobally(confirmation)
    }
    
    func updateNetworkIndicator() {
        for server in ServerManager.shared.servers {
            if server.isConnectingOrRegistering {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                return
            }
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
