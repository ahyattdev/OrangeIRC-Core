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

// Do our own stuff, then forward it to serverDelegate
extension ServerManager {
    
    public func didNotRespond(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.didNotRespond(server)
    }
    
    public func stoppedResponding(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.stoppedResponding(server)
    }
    
    public func startedConnecting(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.startedConnecting(server)
    }
    
    public func didDisconnect(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.didDisconnect(server)
    }
    
    public func registeredSuccessfully(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.registeredSuccessfully(server)
    }
    
    public func received(notice: String, sender: String, on server: Server) {
        serverDelegate?.received(notice: notice, sender: sender, on: server)
    }
    
    public func received(logEvent: LogEvent, for room: Room) {
        NotificationCenter.default.post(name: Notifications.newLogEventForRoom, object: room)
        NotificationCenter.default.post(Notification(name: Notifications.roomDataChanged))
        serverDelegate?.received(logEvent: logEvent, for: room)
    }
    
    public func received(error: String, on server: Server) {
        serverDelegate?.received(error: error, on: server)
    }
    
    public func received(topic: String, for room: Room) {
        NotificationCenter.default.post(name: Notifications.topicUpdatedForRoom, object: room)
        NotificationCenter.default.post(Notification(name: Notifications.roomDataChanged))
        serverDelegate?.received(topic: topic, for: room)
    }
    
    public func finishedReadingUserList(_ room: Room) {
        NotificationCenter.default.post(name: Notifications.userListUpdatedForRoom, object: room)
        serverDelegate?.finishedReadingUserList(room)
    }
    
    public func motdUpdated(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.motdUpdatedForServer, object: server)
        serverDelegate?.motdUpdated(server)
    }
    
    public func chanlistUpdated(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.listUpdatedForServer, object: server)
        serverDelegate?.chanlistUpdated(server)
    }
    
    public func finishedReadingChanlist(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.listFinishedForServer, object: server)
        serverDelegate?.finishedReadingChanlist(server)
    }
    
    public func nickservPasswordNeeded(_ server: Server) {
        serverDelegate?.nickservPasswordNeeded(server)
    }
    
    public func nickservPasswordIncorrect(_ server: Server) {
        serverDelegate?.nickservPasswordIncorrect(server)
    }
    
    public func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: String, date: String) {
        serverDelegate?.nickservFailedAttemptsWarning(server, count: count, lastPrefix: lastPrefix, date: date)
    }
    
    public func infoWasUpdated(_ user: User) {
        NotificationCenter.default.post(name: Notifications.userInfoDidChange, object: user)
        serverDelegate?.infoWasUpdated(user)
    }
    
    public func noSuch(nick: String, _ server: Server) {
        serverDelegate?.noSuch(nick: nick, server)
    }
    
    public func noSuch(server: String, _ onServer: Server) {
        serverDelegate?.noSuch(server: server, onServer)
    }
    
    public func noSuch(channel: String, _ server: Server) {
        serverDelegate?.noSuch(channel: channel, server)
    }
    
    public func cannotSendTo(channel: String, _ server: Server) {
        serverDelegate?.cannotSendTo(channel: channel, server)
    }
    
    public func tooManyChannels(_ server: Server) {
        serverDelegate?.tooManyChannels(server)
    }
    
    public func serverPasswordNeeded(_ server: Server) {
        serverDelegate?.serverPasswordNeeded(server)
    }
    
    public func keyNeeded(channel: Channel, on server: Server) {
        serverDelegate?.keyNeeded(channel: channel, on: server)
    }
    
    public func keyIncorrect(channel: Channel, on server: Server) {
        serverDelegate?.keyIncorrect(channel: channel, on: server)
    }
    
    public func kicked(server: Server, room: Room, sender: User) {
        serverDelegate?.kicked(server: server, room: room, sender: sender)
    }
    
    public func banned(server: Server, channel: Channel) {
        serverDelegate?.banned(server: server, channel: channel)
    }
    
    public func inviteOnly(server: Server, channel: Channel) {
        serverDelegate?.inviteOnly(server: server, channel: channel)
    }

}
