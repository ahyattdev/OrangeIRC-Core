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

/// Functions for handling events
public protocol ServerDelegate {
    
    /// The server did not respond to our attempts to connect
    ///
    /// - Parameter server: Server
    func didNotRespond(_ server: Server)
    /// The server stopped responding
    ///
    /// - Parameter server: Server
    func stoppedResponding(_ server: Server)
    /// The client started connecting
    ///
    /// - Parameter server: Server
    func startedConnecting(_ server: Server)
    /// The client disconnected from the server
    ///
    /// - Parameter server: Server
    func didDisconnect(_ server: Server)
    /// The client registered with the server successfully
    ///
    /// - Parameter server: Server
    func registeredSuccessfully(_ server: Server)
    
    /// A NOTICE was received
    ///
    /// - Parameters:
    ///   - notice: NOTICE text
    ///   - sender: NOTICE sender
    ///   - server: Server
    func received(notice: String, sender: String, on server: Server)
    /// A log event for a room was received
    ///
    /// - Parameters:
    ///   - logEvent: Log event
    ///   - room: Room
    func received(logEvent: LogEvent, for room: Room)
    /// An ERROR message was received from the server
    ///
    /// - Parameters:
    ///   - error: ERROR message from server
    ///   - server: Server
    func received(error: String, on server: Server)
    /// A topic was received for a room
    ///
    /// - Parameters:
    ///   - topic: Topic text
    ///   - room: Room
    func received(topic: String, for room: Room)
    
    /// Reading the user list of a room completed
    ///
    /// - Parameter room: Room
    func finishedReadingUserList(_ room: Room)
    /// The MOTD for a server was updated
    ///
    /// - Parameter server: Server
    func motdUpdated(_ server: Server)
    
    /// A NickServ password is needed
    ///
    /// - Parameter server: Server
    func nickservPasswordNeeded(_ server: Server)
    /// The given NickServ password is incorrect
    ///
    /// - Parameter server: Server
    func nickservPasswordIncorrect(_ server: Server)
    /// Attempts were made to authenticate as our nickname
    ///
    /// - Parameters:
    ///   - server: Server
    ///   - count: Number of attempts
    ///   - lastPrefix: Last prefix of attempt
    ///   - date: Date of attempt
    func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: String, date: String)
    
    /// Information for a user was updated
    ///
    /// - Parameter user: User
    func infoWasUpdated(_ user: User)
    
    /// Some more channels were added to the channel list
    ///
    /// - Parameter server: Server
    func chanlistUpdated(_ server: Server)
    /// Reading the channel list has been completed
    ///
    /// - Parameter server: Server
    func finishedReadingChanlist(_ server: Server)
    
    /// No such nickname on server
    ///
    /// - Parameters:
    ///   - nick: Nickname
    ///   - server: Server
    func noSuch(nick: String, _ server: Server)
    /// No such server on server
    ///
    /// - Parameters:
    ///   - server: Server
    ///   - onServer: Channel
    func noSuch(server: String, _ onServer: Server)
    /// No such channel on server
    ///
    /// - Parameters:
    ///   - channel: Channel
    ///   - server: Server
    func noSuch(channel: String, _ server: Server)
    /// The client can’t send a message to the channel
    ///
    /// - Parameters:
    ///   - channel: Channel
    ///   - server: Server
    func cannotSendTo(channel: String, _ server: Server)
    /// The client is connected to too many channels
    ///
    /// - Parameter server: Server
    func tooManyChannels(_ server: Server)
    /// A password is needed to connect to the server
    ///
    /// - Parameter server: Server
    func serverPasswordNeeded(_ server: Server)
    
    /// A key is needed to connect to the channel
    ///
    /// - Parameters:
    ///   - channel: Channel
    ///   - server: Server
    func keyNeeded(channel: Channel, on server: Server)
    /// The channel key the client gave is incorrect
    ///
    /// - Parameters:
    ///   - channel: Channel
    ///   - server: Server
    func keyIncorrect(channel: Channel, on server: Server)
    
    /// We were kicked from a room
    ///
    /// - Parameters:
    ///   - server: Server
    ///   - room: The room the client was kicked from
    ///   - sender: The user who kicked us
    func kicked(server: Server, room: Room, sender: User)
    /// A connection attempt was made but there is a ban on us
    ///
    /// - Parameters:
    ///   - server: Server
    ///   - channel: Channel
    func banned(server: Server, channel: Channel)
    /// A channel that was attempted to join is invite only
    ///
    /// - Parameters:
    ///   - server: Server
    ///   - channel: Channel
    func inviteOnly(server: Server, channel: Channel)
    
}
