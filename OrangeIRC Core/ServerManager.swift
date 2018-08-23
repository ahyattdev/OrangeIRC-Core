//
//  ServerManager.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 1/14/17.
//
//

import Foundation

/// Designed to manage a set of servers for an application. This is optional and
/// not required to user `Server` but it handles the tasks of loading and saving
/// data so you may find it useful.
///
/// It is designed to be a singleton and it loads the server data when it is
/// initialized.
open class ServerManager {
    
    /// Shared instance
    open static let shared = ServerManager()
    
    /// The servers managed by the server manager
    internal(set) open var servers: [Server]!
    
    private init() {
        loadData()
    }
    
    /// Paths to store data for servers. Can be customized as needed,
    /// defaults to servers.plist in the Documents Directory.
    open var dataPath = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask)[0].appendingPathComponent("servers.plist")
    
    /// The delegate for every server.
    open var serverDelegate: ServerDelegate? {
        didSet {
            servers.forEach{
                $0.delegate = self.serverDelegate
            }
        }
    }
    
    /// Servers for which the client is currently registered with.
    open var registeredServers: [Server] {
        var regServers = [Server]()
        for server in servers {
            if server.isRegistered {
                regServers.append(server)
            }
        }
        return regServers
    }
    
    /// Creates a server with UTF-8 encoding and adds it to the save data.
    ///
    /// - Parameters:
    ///   - host: Server hostname
    ///   - port: Server port
    ///   - nickname: Client preferred nickname
    ///   - username: Client username
    ///   - realname: Client real name
    ///   - password: Server password, optional
    /// - Returns: A created server that is in the save data
    open func addServer(host: String, port: Int, nickname: String, username: String, realname: String, password: String? = nil) -> Server {
        let server = Server(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: String.Encoding.utf8)
        
        // Set the password if one was provided
        if let password = password {
            server.password = password
        }
        
        servers.append(server)
        server.delegate = self.serverDelegate
        server.connect()
        saveData()
        
        NotificationCenter.default.post(name: Notifications.serverCreated, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        
        // Returned so additional configuration can be done
        return server
    }
    
    /// Load client data from `dataPath`.
    open func loadData() {
        guard let loadedServers = NSKeyedUnarchiver.unarchiveObject(withFile: dataPath.path) else {
            // Initialize the file
            servers = [Server]()
            saveData()
            return
        }
        
        servers = loadedServers as! [Server]
        
        for server in servers {
            server.delegate = self.serverDelegate
            if server.autoJoin && !server.isConnectingOrRegistering && !server.isConnected {
                server.connect()
            }
        }
    }
    
    /// Saves the client data to `dataPath`.
    open func saveData() {
        NSKeyedArchiver.archiveRootObject(servers, toFile: dataPath.path)
    }
    
    /// Deletes a server. Also handles disconnecting from it and removing it
    /// from the saved data.
    ///
    /// - Parameter server: The server to delete
    open func delete(server: Server) {
        server.disconnect()
        server.delegate = nil
        for i in 0 ..< servers.count {
            if servers[i] == server {
                servers.remove(at: i)
                break
            }
        }
        
        for room in server.rooms {
            NotificationCenter.default.post(name: Notifications.roomDeleted, object: room)
            NotificationCenter.default.post(name: Notifications.roomDataChanged, object: nil)
        }
        
        NotificationCenter.default.post(name: Notifications.serverDeleted, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        
        saveData()
    }
    
}
