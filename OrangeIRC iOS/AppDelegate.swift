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
class AppDelegate: UIResponder, UIApplicationDelegate, ServerDelegate, UITextFieldDelegate {
    
    struct NickServ {
        
        static let ALREADY_REGISTERED = "This nickname is registered."
        static let AUTH_SUCCESS = "You are now identified for"
        
    }
    
    let dataFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    var dataPaths: (servers: String, options: String)
    
    var window: UIWindow?
    
    var nickservPasswordField: UITextField?
    var doneAction: UIAlertAction?
    
    override init() {
        dataPaths.servers = dataFolder.strings(byAppendingPaths: ["servers.plist"])[0]
        dataPaths.options = ""
        print(dataPaths.servers)
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        self.loadData()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveData()
    }
    
    var servers = [Server]()
    
    var registeredServers: [Server] {
        get {
            var regServers = [Server]()
            for server in self.servers {
                if server.isRegistered {
                    regServers.append(server)
                }
            }
            return regServers
        }
    }
    
    func show(room: Room) {
        NotificationCenter.default.post(name: Notifications.DisplayedRoomDidChange, object: room)
    }
    
    func addServer(host: String, port: Int, nickname: String, username: String, realname: String, password: String) -> Server {
        let server = Server(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: String.Encoding.utf8)
        servers.append(server)
        server.delegate = self
        server.connect()
        self.saveData()
        
        // Returned so additional configuration can be done
        return server
    }
    
    func loadData() {
        guard let servers = NSKeyedUnarchiver.unarchiveObject(withFile: self.dataPaths.servers) else {
            self.saveData()
            return
        }
        self.servers = servers as! [Server]
        for server in self.servers {
            server.delegate = self
            if server.autoJoin {
                server.connect()
            }
        }
    }
    
    func saveData() {
        NSKeyedArchiver.archiveRootObject(self.servers, toFile: self.dataPaths.servers)
    }
    
    func didNotRespond(server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.nickservPasswordField {
            guard let text = textField.text as NSString? else {
                return true
            }
            let finalString = text.replacingCharacters(in: range, with: string)
            
            // Disable the done button if no password is given
            self.doneAction!.isEnabled = !finalString.isEmpty
        }
        
        return true
    }
    
    func recieved(notice: String, sender: String, server: Server) {
        switch sender {
        case "NickServ":
            if notice.contains(NickServ.ALREADY_REGISTERED) {
                if server.nickservPassword.isEmpty {
                    let nicknameRegistered = NSLocalizedString("NICKNAME_REGISTERED", comment: "Nickname registered")
                    let nicknameRegisteredDescription = NSLocalizedString("NICKNAME_REGISTERED_DESCRIPTION", comment: "Provide a password")
                    
                    let nicknamePasswordAlert = UIAlertController(title: nicknameRegistered, message: nicknameRegisteredDescription, preferredStyle: .alert)
                    
                    nicknamePasswordAlert.addTextField(configurationHandler: { (textField) in
                        textField.placeholder = NSLocalizedString("NICKNAME_PASSWORD", comment: "Nickname Password")
                        textField.isSecureTextEntry = true
                        self.nickservPasswordField = textField
                        textField.delegate = self
                    })
                    
                    let done = NSLocalizedString("DONE", comment: "Done")
                    let doneAction = UIAlertAction(title: done, style: .default, handler: { (action) in
                        server.nickservPassword = self.nickservPasswordField!.text!
                        self.saveData()
                        server.sendNickServPassword()
                        
                        self.nickservPasswordField?.delegate = nil
                        self.nickservPasswordField = nil
                        self.doneAction = nil
                    })
                    doneAction.isEnabled = false
                    self.doneAction = doneAction
                    
                    nicknamePasswordAlert.addAction(doneAction)
                    
                    let disconnect = NSLocalizedString("DISCONNECT", comment: "Disconnect")
                    let disconnectAction = UIAlertAction(title: disconnect, style: .destructive, handler: { (action) in
                        server.disconnect()
                    })
                    nicknamePasswordAlert.addAction(disconnectAction)
                    
                    self.window!.rootViewController!.present(nicknamePasswordAlert, animated: true, completion: nil)
                } else {
                    // This normally happens after each connection
                    server.sendNickServPassword()
                }
            } else if notice.contains(NickServ.AUTH_SUCCESS) {
                // TODO: Do something here
            } else {
                print("Unknown NickServ message: \(notice)")
            }
        default:
            // TODO: Present a dialog with the information from the NOTICE
            break
        }
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
            for i in 0 ..< self.servers.count {
                if self.servers[i] == server {
                    for room in self.servers[i].rooms {
                        NotificationCenter.default.post(name: Notifications.RoomDataDidChange, object: room)
                    }
                    self.servers.remove(at: i)
                    break
                }
            }
            
            NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
            
            self.saveData()
        })
        confirmation.addAction(deleteAction)
        
        self.window!.rootViewController!.present(confirmation, animated: true, completion: nil)
    }
    
    func finishedReadingUserList(room: Room) {
        dataChanged(room: room)
    }
    
    func recievedTopic(room: Room) {
        dataChanged(room: room)
    }
    
    func joined(room: Room) {
        dataChanged(room: room)
    }
    
    func left(room: Room) {
        dataChanged(room: room)
    }
    
    func startedConnecting(server: Server) {
        self.serverStateChanged()
    }
    
    func finishedReadingMOTD(server: Server) {
        
    }
    
    func didDisconnect(server: Server) {
        self.serverStateChanged()
    }
    
    func dataChanged(room: Room) {
        NotificationCenter.default.post(name: Notifications.RoomDataDidChange, object: room)
        self.saveData()
    }
    
    func serverStateChanged() {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
        self.saveData()
    }
    
}

