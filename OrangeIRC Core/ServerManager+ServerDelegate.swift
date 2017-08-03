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
    
    open func didNotRespond(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.ServerDataChanged, object: nil)
        serverDelegate?.didNotRespond(server)
    }
    
    open func stoppedResponding(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.ServerDataChanged, object: nil)
        serverDelegate?.stoppedResponding(server)
    }
    
    open func startedConnecting(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.ServerDataChanged, object: nil)
        serverDelegate?.startedConnecting(server)
    }
    
    open func didDisconnect(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.ServerDataChanged, object: nil)
        serverDelegate?.didDisconnect(server)
    }
    
    open func registeredSuccessfully(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ServerStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.ServerDataChanged, object: nil)
        serverDelegate?.registeredSuccessfully(server)
    }
    
    open func recieved(notice: String, sender: String, on server: Server) {
        serverDelegate?.received(notice: notice, sender: sender, on: server)
    }
    
    open func recieved(logEvent: LogEvent, for room: Room) {
        NotificationCenter.default.post(name: Notifications.NewLogEventForRoom, object: room)
        NotificationCenter.default.post(Notification(name: Notifications.RoomDataChanged))
        serverDelegate?.received(logEvent: logEvent, for: room)
    }
    
    open func recieved(error: String, on server: Server) {
        serverDelegate?.received(error: error, on: server)
    }
    
    open func recieved(topic: String, for room: Room) {
        NotificationCenter.default.post(name: Notifications.TopicUpdatedForRoom, object: room)
        NotificationCenter.default.post(Notification(name: Notifications.RoomDataChanged))
        serverDelegate?.received(topic: topic, for: room)
    }
    
    open func finishedReadingUserList(_ room: Room) {
        NotificationCenter.default.post(name: Notifications.UserListUpdatedForRoom, object: room)
        serverDelegate?.finishedReadingUserList(room)
    }
    
    open func motdUpdated(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.MOTDUpdatedForServer, object: server)
        serverDelegate?.motdUpdated(server)
    }
    
    open func chanlistUpdated(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ListUpdatedForServer, object: server)
        serverDelegate?.chanlistUpdated(server)
    }
    
    open func finishedReadingChanlist(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.ListFinishedForServer, object: server)
        serverDelegate?.finishedReadingChanlist(server)
    }
    
    open func nickservPasswordNeeded(_ server: Server) {
        serverDelegate?.nickservPasswordNeeded(server)
    }
    
    open func nickservPasswordIncorrect(_ server: Server) {
        serverDelegate?.nickservPasswordIncorrect(server)
    }
    
    open func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: Message.Prefix, date: String) {
        serverDelegate?.nickservFailedAttemptsWarning(server, count: count, lastPrefix: lastPrefix, date: date)
    }
    
    open func infoWasUpdated(_ user: User) {
        NotificationCenter.default.post(name: Notifications.UserInfoDidChange, object: user)
        serverDelegate?.infoWasUpdated(user)
    }
    
    open func noSuch(nick: String, _ server: Server) {
        serverDelegate?.noSuch(nick: nick, server)
    }
    
    open func noSuch(server: String, _ onServer: Server) {
        serverDelegate?.noSuch(server: server, onServer)
    }
    
    open func noSuch(channel: String, _ server: Server) {
        serverDelegate?.noSuch(channel: channel, server)
    }
    
    open func cannotSendTo(channel: String, _ server: Server) {
        serverDelegate?.cannotSendTo(channel: channel, server)
    }
    
    open func tooManyChannels(_ server: Server) {
        serverDelegate?.tooManyChannels(server)
    }
    
    open func serverPaswordNeeed(_ server: Server) {
        serverDelegate?.serverPasswordNeeded(server)
    }
    
    open func keyNeeded(channel: Channel, on server: Server) {
        serverDelegate?.keyNeeded(channel: channel, on: server)
    }
    
    open func keyIncorrect(channel: Channel, on server: Server) {
        serverDelegate?.keyIncorrect(channel: channel, on: server)
    }
    
    open func kicked(server: Server, room: Room, sender: User) {
        serverDelegate?.kicked(server: server, room: room, sender: sender)
    }
    
    open func banned(server: Server, channel: Channel) {
        serverDelegate?.banned(server: server, channel: channel)
    }
    
    open func inviteOnly(server: Server, channel: Channel) {
        serverDelegate?.inviteOnly(server: server, channel: channel)
    }

}
