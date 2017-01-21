//
//  ServerManager+ServerDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 1/21/17.
//
//

import Foundation

// Do our own stuff, then forward it to serverDelegate
extension ServerManager {
    
    public func didNotRespond(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        serverDelegate?.didNotRespond(server)
    }
    
    public func stoppedResponding(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        serverDelegate?.stoppedResponding(server)
    }
    
    public func startedConnecting(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        serverDelegate?.startedConnecting(server)
    }
    
    public func didDisconnect(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        serverDelegate?.didDisconnect(server)
    }
    
    public func registeredSuccessfully(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        serverDelegate?.registeredSuccessfully(server)
    }
    
    public func recieved(notice: String, sender: String, on server: Server) {
        serverDelegate?.recieved(notice: notice, sender: sender, on: server)
    }
    
    public func recieved(logEvent: LogEvent, for room: Room) {
        NotificationCenter.default.post(name: Notifications.NewLogEventForRoom, object: room)
        serverDelegate?.recieved(logEvent: logEvent, for: room)
    }
    
    public func recieved(error: String, on server: Server) {
        serverDelegate?.recieved(error: error, on: server)
    }
    
    public func recieved(topic: String, for room: Room) {
        NotificationCenter.default.post(name: Notifications.TopicUpdatedForRoom, object: room)
        serverDelegate?.recieved(topic: topic, for: room)
    }
    
    public func finishedReadingUserList(_ room: Room) {
        NotificationCenter.default.post(name: Notifications.UserListUpdatedForRoom, object: room)
        serverDelegate?.finishedReadingUserList(room)
    }
    
    public func motdUpdated(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.MOTDUpdatedForServer, object: server)
        serverDelegate?.motdUpdated(server)
    }
    
    public func nickservPasswordNeeded(_ server: Server) {
        serverDelegate?.nickservPasswordNeeded(server)
    }
    
    public func nickservPasswordIncorrect(_ server: Server) {
        serverDelegate?.nickservPasswordIncorrect(server)
    }
    
    public func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: Message.Prefix, date: String) {
        serverDelegate?.nickservFailedAttemptsWarning(server, count: count, lastPrefix: lastPrefix, date: date)
    }
    
    public func infoWasUpdated(_ user: User) {
        NotificationCenter.default.post(name: Notifications.UserInfoDidChange, object: user)
        serverDelegate?.infoWasUpdated(user)
    }
    
}
