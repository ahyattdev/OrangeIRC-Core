// This file of part of the Swift IRC client framework OrangeIRC Core.
//
// Copyright © 2016 Andrew Hyatt
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

/// Designed to manage a set of servers for an application. This is optional and
/// not required to user `Server` but it handles the tasks of loading and saving
/// data so you may find it useful.
///
/// It is designed to be a singleton and it loads the server data when it is
/// initialized.
open class ServerManager : ServerDelegate {
    
    /// Shared instance
    public static let shared = ServerManager()
    
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
    open var serverDelegate: ServerDelegate?
    
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
        server.delegate = self
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
        
        servers = loadedServers as? [Server]
        
        for server in servers {
            server.delegate = self
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
