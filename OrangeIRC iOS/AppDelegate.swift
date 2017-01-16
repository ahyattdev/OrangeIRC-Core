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
    let splitView = UISplitViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        splitView.delegate = self
        
        splitView.preferredDisplayMode = .allVisible
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window!.rootViewController = splitView
        
        window!.tintColor = UIColor.orange
        
        ServerManager.shared.loadData()
        
        splitView.viewControllers = [
            UINavigationController(rootViewController: RoomsTableViewController(style: .plain)),
            UINavigationController(rootViewController: UITableViewController(style: .plain))
        ]
        
        ServerManager.shared.serverDelegate = self
        
        window!.makeKeyAndVisible()
        
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
    func showAlertGlobally(_ alert: UIAlertController) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert
        alertWindow.rootViewController = vc
        alertWindow.makeKeyAndVisible()
        vc.present(alert, animated: true, completion: nil)
    }
    
    func recieved(notice: String, sender: String, server: Server) {
        var title = NSLocalizedString("NOTICE_FROM_ON", comment: "")
        title = title.replacingOccurrences(of: "[USERNAME]", with: sender)
        title = title.replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        let alert = UIAlertController(title: title, message: notice, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        
        showAlertGlobally(alert)
    }
    
    func delete(room: Room) {
        let server = room.server!
        
        // Leave gracefully
        if room.isJoined {
            server.leave(channel: room.name)
        }
        
        // Remove from the array of rooms of the server of this room
        for i in 0 ..< server.rooms.count {
            if server.rooms[i] == room {
                server.rooms.remove(at: i)
                break
            }
        }
        
        // Remove from the AppDelegate array of rooms
        for i in 0 ..< ServerManager.shared.rooms.count {
            if ServerManager.shared.rooms[i] == room {
                ServerManager.shared.rooms.remove(at: i)
                break
            }
        }
        
        ServerManager.shared.saveData()
        dataChanged(room: nil)
    }
    
    func delete(server: Server) {
        let title = NSLocalizedString("DELETE_SERVER", comment: "Delete server").replacingOccurrences(of: "[SERVER]", with: server.host)
        let message = NSLocalizedString("DELETE_SERVER_DESCRIPTION", comment: "Delete server description")
        let confirmation = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil)
        confirmation.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete"), style: .destructive, handler: { (action) in
            server.disconnect()
            server.delegate = nil
            for i in 0 ..< ServerManager.shared.servers.count {
                if ServerManager.shared.servers[i] == server {
                    ServerManager.shared.servers.remove(at: i)
                    break
                }
            }
            
            NotificationCenter.default.post(name: Notifications.RoomDataDidChange, object: nil)
            
            NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
            
            ServerManager.shared.saveData()
        })
        confirmation.addAction(deleteAction)
        
        showAlertGlobally(confirmation)
    }
    
    func didNotRespond(server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
        
        let message = NSLocalizedString("SERVER_DID_NOT_RESPOND_DESCRIPTION", comment: "").replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        let alert = UIAlertController(title: NSLocalizedString("SERVER_DID_NOT_RESPOND", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        showAlertGlobally(alert)
    }
    
    func stoppedResponding(server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
    }
    
    func connectedSucessfully(server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
    }
    
    func didRegister(server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
    }
    
    func finishedReadingUserList(room: Room) {
        dataChanged(room: room)
    }
    
    func recievedTopic(room: Room) {
        dataChanged(room: room)
    }
    
    func joined(room: Room) {
        if !ServerManager.shared.rooms.contains(room) {
            ServerManager.shared.rooms.append(room)
            ServerManager.shared.saveData()
        }
        
        dataChanged(room: room)
    }
    
    func left(room: Room) {
        dataChanged(room: room)
    }
    
    func startedConnecting(server: Server) {
        serverStateChanged()
    }
    
    func finishedReadingMOTD(server: Server) {
        
    }
    
    func didDisconnect(server: Server) {
        dataChanged(room: nil)
        serverStateChanged()
    }
    
    func recieved(logEvent: LogEvent, for room: Room) {
        NotificationCenter.default.post(name: Notifications.RoomLogDidChange, object: room)
    }
    
    func dataChanged(room: Room?) {
        NotificationCenter.default.post(name: Notifications.RoomDataDidChange, object: room)
        ServerManager.shared.saveData()
    }
    
    func serverStateChanged() {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
        ServerManager.shared.saveData()
    }
    
    func recieved(error: String, server: Server) {
        let fullError = "\(NSLocalizedString("ERROR_DISCONNECT_MESSAGE", comment: "")):\n\n\(error)"
        
        let alert = UIAlertController(title: server.host, message: fullError, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
        alert.addAction(ok)
        
        showAlertGlobally(alert)
    }
    
    func nickservPasswordNeeded(_ server: Server) {
        let nicknameRegistered = NSLocalizedString("NICKNAME_REGISTERED", comment: "Nickname registered")
        let nicknameRegisteredDescription = NSLocalizedString("NICKNAME_REGISTERED_DESCRIPTION", comment: "Provide a password")
        
        let nicknamePasswordAlert = UIAlertController(title: nicknameRegistered, message: nicknameRegisteredDescription, preferredStyle: .alert)
        
        nicknamePasswordAlert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = NSLocalizedString("NICKNAME_PASSWORD", comment: "Nickname Password")
            textField.isSecureTextEntry = true
            self.nickservPasswordField = textField
            textField.delegate = self
        })
        
        let disconnect = NSLocalizedString("DISCONNECT", comment: "Disconnect")
        let disconnectAction = UIAlertAction(title: disconnect, style: .destructive, handler: { (action) in
            server.disconnect()
        })
        nicknamePasswordAlert.addAction(disconnectAction)
        
        let done = NSLocalizedString("AUTHENTICATE", comment: "Done")
        let doneAction = UIAlertAction(title: done, style: .default, handler: { (action) in
            server.nickservPassword = self.nickservPasswordField!.text!
            ServerManager.shared.saveData()
            server.sendNickServPassword()
            
            self.nickservPasswordField?.delegate = nil
            self.nickservPasswordField = nil
            self.doneAction = nil
        })
        doneAction.isEnabled = false
        self.doneAction = doneAction
        
        nicknamePasswordAlert.addAction(doneAction)
        
        showAlertGlobally(nicknamePasswordAlert)
    }
    
    func nickservPasswordIncorrect(_ server: Server) {
        let title = NSLocalizedString("NICKNAME_PASSWORD_INCORRECT", comment: "")
        var message = NSLocalizedString("PROVIDE_CORRECT_PASSWORD", comment: "")
        message = message.replacingOccurrences(of: "[NICKNAME]", with: server.nickname)
        message = message.replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = NSLocalizedString("NICKNAME_PASSWORD", comment: "Nickname Password")
            textField.isSecureTextEntry = true
            self.nickservPasswordField = textField
            textField.delegate = self
        })
        
        let disconnect = NSLocalizedString("DISCONNECT", comment: "Disconnect")
        let disconnectAction = UIAlertAction(title: disconnect, style: .destructive, handler: { (action) in
            server.disconnect()
        })
        alert.addAction(disconnectAction)
        
        let authenticate = NSLocalizedString("AUTHENTICATE", comment: "")
        let authAction = UIAlertAction(title: authenticate, style: .default, handler: { (action) in
            server.nickservPassword = self.nickservPasswordField!.text!
            ServerManager.shared.saveData()
            server.sendNickServPassword()
            
            self.nickservPasswordField?.delegate = nil
            self.nickservPasswordField = nil
            self.doneAction = nil
        })
        authAction.isEnabled = false
        doneAction = authAction
        alert.addAction(authAction)
        
        showAlertGlobally(alert)
    }
    
    func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: Message.Prefix, date: String) {
        guard let nickname = lastPrefix.nickname,
            let username = lastPrefix.user,
            let hostname = lastPrefix.host else {
                return
        }
        
        let title = NSLocalizedString("FAILED_ATTEMPTS_NICKSERV", comment: "")
        var message = NSLocalizedString("FAILED_ATTEMPTS_NICKSERV_MESSAGE", comment: "")
        message = message.replacingOccurrences(of: "[NUM]", with: "\(count)")
        message = message.replacingOccurrences(of: "[MYNICK]", with: server.nickname)
        message = message.replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        message = message.replacingOccurrences(of: "[NICKNAME]", with: nickname)
        message = message.replacingOccurrences(of: "[USERNAME]", with: username)
        message = message.replacingOccurrences(of: "[HOSTNAME]", with: hostname)
        message = message.replacingOccurrences(of: "[DATE]", with: date)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        
        showAlertGlobally(alert)
    }
    
    func infoWasUpdated(_ user: User) {
        NotificationCenter.default.post(name: Notifications.UserInfoDidChange, object: user)
    }
    
}
