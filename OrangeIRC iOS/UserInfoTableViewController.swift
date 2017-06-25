//
//  UserInfoTableViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/26/16.
//
//

import UIKit
import OrangeIRCCore

class UserInfoTableViewController : UITableViewController {
    
    let rowNames = [
        [
            localized("CLASS"),
            localized("AWAY_INFO")
        ], [
            localized("IP_ADDRESS"),
            localized("HOSTNAME"),
            localized("USERNAME"),
            localized("REAL_NAME")
        ], [
            localized("SERVER"),
            localized("ROOMS")
        ], [
            localized("CONNECTED"),
            localized("IDLE")
        ], [
            localized("PING"),
            localized("LOCAL_TIME"),
            localized("CLIENT_INFO")
        ]
    ]
    
    var rowData = [[String?]]()
    
    var user: User
    var server: Server
    
    init(user: User, server: Server) {
        // Populate rowData
        for i in 0 ..< rowNames.count {
            rowData.append([String?]())
            for _ in 0 ..< rowNames[i].count {
                rowData[i].append(nil)
            }
        }
        
        self.user = user
        self.server = server
        
        super.init(style: .grouped)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: Notifications.UserInfoDidChange, object: user)
        server.fetchInfo(user)
    }
    
    func updateData() {
        // Class
        if let `class` = user.class {
            switch `class` {
                
            case .Operator:
                rowData[0][0] = localized("OPERATOR")
                
            case .Normal:
                rowData[0][0] = localized("NORMAL")
                
            }
        }
        
        // Away info
        if let away = user.away {
            if away, let awayMessage = user.awayMessage {
                rowData[0][1] = awayMessage
            } else {
                rowData[0][1] = localized("NOT_AWAY")
            }
        }
        
        // IP
        rowData[1][0] = user.ip
        
        // Host
        rowData[1][1] = user.host
        
        // Username
        rowData[1][2] = user.username
        
        // Realname
        rowData[1][3] = user.realname
        
        // Servername
        rowData[2][0] = user.servername
        
        // Rooms
        if let rooms = user.channelList {
            var roomStr = ""
            for room in rooms {
                roomStr.append("\(room) ")
            }
            if !roomStr.isEmpty {
                roomStr = roomStr[roomStr.startIndex ..< roomStr.index(before: roomStr.endIndex)]
            }
            rowData[2][1] = roomStr
        }
        
        let now = Date()
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        
        // Connected
        if let online = user.onlineTime {
            rowData[3][0] = formatter.string(from: online, to: now)
        }
        
        // Idle
        if let idle = user.idleTime {
            rowData[3][1] = formatter.string(from: idle, to: now)
        }
    }
    
    func handle(_ notification: NSNotification) {
        if notification.name == Notifications.UserInfoDidChange {
            updateData()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = user.nick
        navigationItem.prompt = server.displayName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rowNames.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowNames[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let data = rowData[indexPath.section][indexPath.row] {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = rowNames[indexPath.section][indexPath.row]
            cell.detailTextLabel?.text = data
            cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
            return cell
        } else {
            let cell = ActivityIndicatorCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = rowNames[indexPath.section][indexPath.row]
            cell.activityIndicator.startAnimating()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return rowData[indexPath.section][indexPath.row] != nil
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)), let data = rowData[indexPath.section][indexPath.row] {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = data
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
