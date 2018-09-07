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
    
    private func didNotRespond(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.didNotRespond(server)
    }
    
    private func stoppedResponding(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.stoppedResponding(server)
    }
    
    private func startedConnecting(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.startedConnecting(server)
    }
    
    private func didDisconnect(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.didDisconnect(server)
    }
    
    private func registeredSuccessfully(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.serverStateDidChange, object: server)
        NotificationCenter.default.post(name: Notifications.serverDataChanged, object: nil)
        serverDelegate?.registeredSuccessfully(server)
    }
    
    private func recieved(notice: String, sender: String, on server: Server) {
        serverDelegate?.received(notice: notice, sender: sender, on: server)
    }
    
    private func recieved(logEvent: LogEvent, for room: Room) {
        NotificationCenter.default.post(name: Notifications.newLogEventForRoom, object: room)
        NotificationCenter.default.post(Notification(name: Notifications.roomDataChanged))
        serverDelegate?.received(logEvent: logEvent, for: room)
    }
    
    private func recieved(error: String, on server: Server) {
        serverDelegate?.received(error: error, on: server)
    }
    
    private func recieved(topic: String, for room: Room) {
        NotificationCenter.default.post(name: Notifications.topicUpdatedForRoom, object: room)
        NotificationCenter.default.post(Notification(name: Notifications.roomDataChanged))
        serverDelegate?.received(topic: topic, for: room)
    }
    
    private func finishedReadingUserList(_ room: Room) {
        NotificationCenter.default.post(name: Notifications.userListUpdatedForRoom, object: room)
        serverDelegate?.finishedReadingUserList(room)
    }
    
    private func motdUpdated(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.motdUpdatedForServer, object: server)
        serverDelegate?.motdUpdated(server)
    }
    
    private func chanlistUpdated(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.listUpdatedForServer, object: server)
        serverDelegate?.chanlistUpdated(server)
    }
    
    private func finishedReadingChanlist(_ server: Server) {
        NotificationCenter.default.post(name: Notifications.listFinishedForServer, object: server)
        serverDelegate?.finishedReadingChanlist(server)
    }
    
    private func nickservPasswordNeeded(_ server: Server) {
        serverDelegate?.nickservPasswordNeeded(server)
    }
    
    private func nickservPasswordIncorrect(_ server: Server) {
        serverDelegate?.nickservPasswordIncorrect(server)
    }
    
    private func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: String, date: String) {
        serverDelegate?.nickservFailedAttemptsWarning(server, count: count, lastPrefix: lastPrefix, date: date)
    }
    
    private func infoWasUpdated(_ user: User) {
        NotificationCenter.default.post(name: Notifications.userInfoDidChange, object: user)
        serverDelegate?.infoWasUpdated(user)
    }
    
    private func noSuch(nick: String, _ server: Server) {
        serverDelegate?.noSuch(nick: nick, server)
    }
    
    private func noSuch(server: String, _ onServer: Server) {
        serverDelegate?.noSuch(server: server, onServer)
    }
    
    private func noSuch(channel: String, _ server: Server) {
        serverDelegate?.noSuch(channel: channel, server)
    }
    
    private func cannotSendTo(channel: String, _ server: Server) {
        serverDelegate?.cannotSendTo(channel: channel, server)
    }
    
    private func tooManyChannels(_ server: Server) {
        serverDelegate?.tooManyChannels(server)
    }
    
    private func serverPaswordNeeed(_ server: Server) {
        serverDelegate?.serverPasswordNeeded(server)
    }
    
    private func keyNeeded(channel: Channel, on server: Server) {
        serverDelegate?.keyNeeded(channel: channel, on: server)
    }
    
    private func keyIncorrect(channel: Channel, on server: Server) {
        serverDelegate?.keyIncorrect(channel: channel, on: server)
    }
    
    private func kicked(server: Server, room: Room, sender: User) {
        serverDelegate?.kicked(server: server, room: room, sender: sender)
    }
    
    private func banned(server: Server, channel: Channel) {
        serverDelegate?.banned(server: server, channel: channel)
    }
    
    private func inviteOnly(server: Server, channel: Channel) {
        serverDelegate?.inviteOnly(server: server, channel: channel)
    }

}
