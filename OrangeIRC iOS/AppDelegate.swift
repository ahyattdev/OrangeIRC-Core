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
class AppDelegate: UIResponder, UIApplicationDelegate, ServerDelegate {
    
    struct NickServ {
        
        static let ALREADY_REGISTERED = "This nickname is registered."
        
    }
    
    let dataFolder: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var dataPaths: (servers: String, options: String)
    
    var window: UIWindow?
    
    override init() {
        dataPaths.servers = dataFolder.strings(byAppendingPaths: ["servers.plist"])[0]
        dataPaths.options = ""
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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
    
    func addServer(host: String, port: Int, nickname: String, username: String, realname: String, password: String) {
        let server = Server(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: String.Encoding.utf8)
        servers.append(server)
        server.delegate = self
        server.connect()
        self.saveData()
    }
    
    func loadData() {
        guard let servers = NSKeyedUnarchiver.unarchiveObject(withFile: self.dataPaths.servers) else {
            self.saveData()
            return
        }
        self.servers = servers as! [Server]
        for server in self.servers {
            server.delegate = self
        }
    }
    
    func saveData() {
        NSKeyedArchiver.archiveRootObject(self.servers, toFile: self.dataPaths.servers)
    }
    
    func didNotRespond(server: Server) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ServerStateDidChange), object: nil)
    }
    
    func stoppedResponding(server: Server) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ServerStateDidChange), object: nil)
    }
    
    func connectedSucessfully(server: Server) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ServerStateDidChange), object: nil)
    }
    
    func didRegister(server: Server) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ServerStateDidChange), object: nil)
    }
    
    func recieved(notice: String, sender: String, server: Server) {
        switch sender {
        case "NickServ":
            if notice.contains(NickServ.ALREADY_REGISTERED) {
                // TODO: Display a dialog prompting for the password
            } else {
                print("Unknown NickServ message: \(notice)")
            }
        default:
            // TODO: Present a dialog with the information from the NOTICE
            break
        }
    }
    
    func finishedReadingUserList(room: Room) {
        
    }
    
    func recievedTopic(room: Room) {
        
    }
    
    func joined(room: Room) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.RoomDataDidChange), object: nil)
    }
    
    func startedConnecting(server: Server) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ServerStateDidChange), object: nil)
    }
    
    func finishedReadingMOTD(server: Server) {
        
    }
    
    func didDisconnect(server: Server) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ServerStateDidChange), object: nil)
    }
    
}

