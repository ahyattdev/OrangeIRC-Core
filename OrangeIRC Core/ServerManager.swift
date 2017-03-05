//
//  ServerManager.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 1/14/17.
//
//

import Foundation

public class ServerManager : ServerDelegate {
    
    // Singleton
    public static let shared = ServerManager()
    
    // Saved data
    public var servers: [Server]!
    
    private init() {
        loadData()
    }
    
    // Runtime data
    public var dataPaths: (servers: URL, rooms: URL) = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("servers.plist"),
                                                 FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("rooms.plist"))
    
    // Set by whatever uses this framework
    public var serverDelegate: ServerDelegate?
    
    // Dynamic variables
    public var registeredServers: [Server] {
        var regServers = [Server]()
        for server in servers {
            if server.isRegistered {
                regServers.append(server)
            }
        }
        return regServers
    }
    
    public func addServer(host: String, port: Int, nickname: String, username: String, realname: String, password: String) -> Server {
        let server = Server(host: host, port: port, nickname: nickname, username: username, realname: realname, encoding: String.Encoding.utf8)
        servers.append(server)
        server.delegate = self
        server.connect()
        saveData()
        
        NotificationCenter.default.post(name: Notifications.ServerCreated, object: server)
        NotificationCenter.default.post(name: Notifications.ServerDataChanged, object: nil)
        
        // Returned so additional configuration can be done
        return server
    }
    
    public func loadData() {
        guard let loadedServers = NSKeyedUnarchiver.unarchiveObject(withFile: dataPaths.servers.path) else {
            // Initialize the file
            servers = [Server]()
            saveData()
            return
        }
        
        servers = loadedServers as! [Server]
        
        for server in servers {
            server.delegate = self
            if server.autoJoin {
                server.connect()
            }
        }
    }
    
    public func saveData() {
        NSKeyedArchiver.archiveRootObject(servers, toFile: dataPaths.servers.path)
    }
    

    
    public func delete(server: Server) {
        server.disconnect()
        server.delegate = nil
        for i in 0 ..< servers.count {
            if servers[i] == server {
                servers.remove(at: i)
                break
            }
        }
        
        for room in server.rooms {
            NotificationCenter.default.post(name: Notifications.RoomDeleted, object: room)
            NotificationCenter.default.post(name: Notifications.RoomDataChanged, object: nil)
        }
        
        NotificationCenter.default.post(name: Notifications.ServerDeleted, object: server)
        NotificationCenter.default.post(name: Notifications.ServerDataChanged, object: nil)
        
        saveData()
    }
    
}
