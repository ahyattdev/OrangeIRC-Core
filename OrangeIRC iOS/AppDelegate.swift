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
    
    struct NickServ {
        
        private init() { }
        
        static let ALREADY_REGISTERED = "This nickname is registered."
        static let AUTH_SUCCESS = "You are now identified for"
        
    }
    
    let dataFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    var dataPaths: (servers: String, rooms: String)
    
    var window: UIWindow?
    
    var nickservPasswordField: UITextField?
    var doneAction: UIAlertAction?
    
    // View controllers
    var splitView = UISplitViewController()
    var roomsView = RoomsViewController()
    var roomView = RoomViewController()
    
    // Saved data
    var servers = [Server]()
    var rooms = [Room]()
    
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
    
    override init() {
        dataPaths.servers = dataFolder.strings(byAppendingPaths: ["servers.plist"])[0]
        dataPaths.rooms = dataFolder.strings(byAppendingPaths: ["rooms.plist"])[0]
        
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        splitView.delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window!.rootViewController = splitView
        
        let roomsNav = UINavigationController()
        
        let roomNav = UINavigationController()
        
        splitView.viewControllers = [roomsNav, roomNav]
        
        roomsNav.show(roomsView, sender: nil)
        roomNav.show(roomView, sender: nil)
        
        window!.tintColor = UIColor.orange
        window!.makeKeyAndVisible()
        
        loadData()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData()
    }
    
    func show(room: Room) {
        if splitView.isCollapsed {
            // Done on iPhone
            roomView.updateWith(room: room)
            roomsView.navigationController?.pushViewController(roomView, animated: true)
        } else {
            // We can only use the notification if the view controller will exist
            NotificationCenter.default.post(name: Notifications.DisplayedRoomDidChange, object: room)
        }
    }
    
    func addServer(host: String, port: Int, nickname: String, username: String, realname: String, password: String) -> Server {
        let server = Server(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: String.Encoding.utf8)
        servers.append(server)
        server.delegate = self
        server.connect()
        saveData()
        
        // Returned so additional configuration can be done
        return server
    }
    
    func loadData() {
        guard let servers = NSKeyedUnarchiver.unarchiveObject(withFile: dataPaths.servers) else {
            // Initialize the file
            saveData()
            return
        }
        
        self.servers = servers as! [Server]
        
        guard let rooms = NSKeyedUnarchiver.unarchiveObject(withFile: dataPaths.rooms) else {
            // Initialize the file
            self.rooms = [Room]()
            saveData()
            return
        }
        
        self.rooms = rooms as! [Room]
        for room in self.rooms {
            guard let server = server(for: room.serverUUID) else {
                fatalError("A room without a matching server was loaded")
            }
            room.server = server
            server.rooms.append(room)
        }
        
        for server in self.servers {
            server.delegate = self
            if server.autoJoin {
                server.connect()
            }
        }
    }
    
    func saveData() {
        NSKeyedArchiver.archiveRootObject(servers, toFile: dataPaths.servers)
        NSKeyedArchiver.archiveRootObject(rooms, toFile: dataPaths.rooms)
    }
    
    func server(for uuid: UUID) -> Server? {
        for server in servers {
            if server.uuid == uuid {
                return server
            }
        }
        return nil
    }
    
    func rooms(for server: Server) -> [Room] {
        var roomsOfServer = [Room]()
        for room in rooms {
            if room.serverUUID == server.uuid {
                roomsOfServer.append(room)
                room.server = server
            }
        }
        return roomsOfServer
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
                    
                    let disconnect = NSLocalizedString("DISCONNECT", comment: "Disconnect")
                    let disconnectAction = UIAlertAction(title: disconnect, style: .destructive, handler: { (action) in
                        server.disconnect()
                    })
                    nicknamePasswordAlert.addAction(disconnectAction)
                    
                    let done = NSLocalizedString("AUTHENTICATE", comment: "Done")
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
                    
                    window!.rootViewController!.present(nicknamePasswordAlert, animated: true, completion: nil)
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
                    self.servers.remove(at: i)
                    break
                }
            }
            
            NotificationCenter.default.post(name: Notifications.RoomDataDidChange, object: nil)
            
            NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
            
            self.saveData()
        })
        confirmation.addAction(deleteAction)
        
        window!.rootViewController!.present(confirmation, animated: true, completion: nil)
    }
    
    func delete(room: Room) {
        let server = room.server!
        
        // Leave gracefully
        server.leave(channel: room.name)
        
        // Remove from the array of rooms of the server of this room
        for i in 0 ..< server.rooms.count {
            if server.rooms[i] == room {
                server.rooms.remove(at: i)
                break
            }
        }
        
        // Remove from the AppDelegate array of rooms
        for i in 0 ..< rooms.count {
            if rooms[i] == room {
                rooms.remove(at: i)
                break
            }
        }
        
        saveData()
        dataChanged(room: nil)
    }
    
    func didNotRespond(server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
        
        let message = NSLocalizedString("SERVER_DID_NOT_RESPOND_DESCRIPTION", comment: "").replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        let alert = UIAlertController(title: NSLocalizedString("SERVER_DID_NOT_RESPOND", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        window!.rootViewController!.present(alert, animated: true, completion: nil)
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
        if !rooms.contains(room) {
            rooms.append(room)
            saveData()
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
        saveData()
    }
    
    func serverStateChanged() {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: nil)
        saveData()
    }
    
    func recieved(error: String, server: Server) {
        let fullError = "\(NSLocalizedString("ERROR_DISCONNECT_MESSAGE", comment: "")):\n\n\(error)"
        
        let alert = UIAlertController(title: server.host, message: fullError, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
        alert.addAction(ok)
        
        window!.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
}
