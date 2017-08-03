//
//  ServerDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation

public protocol ServerDelegate {
    
    func didNotRespond(_ server: Server)
    func stoppedResponding(_ server: Server)
    func startedConnecting(_ server: Server)
    func didDisconnect(_ server: Server)
    func registeredSuccessfully(_ server: Server)
    
    func received(notice: String, sender: String, on server: Server)
    func received(logEvent: LogEvent, for room: Room)
    func received(error: String, on server: Server)
    func received(topic: String, for room: Room)
    
    func finishedReadingUserList(_ room: Room)
    func motdUpdated(_ server: Server)
    
    func nickservPasswordNeeded(_ server: Server)
    func nickservPasswordIncorrect(_ server: Server)
    func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: Message.Prefix, date: String)
    
    func infoWasUpdated(_ user: User)
    
    func chanlistUpdated(_ server: Server)
    func finishedReadingChanlist(_ server: Server)
    
    func noSuch(nick: String, _ server: Server)
    func noSuch(server: String, _ onServer: Server)
    func noSuch(channel: String, _ server: Server)
    func cannotSendTo(channel: String, _ server: Server)
    func tooManyChannels(_ server: Server)
    func serverPasswordNeeded(_ server: Server)
    
    func keyNeeded(channel: Channel, on server: Server)
    func keyIncorrect(channel: Channel, on server: Server)
    
    func kicked(server: Server, room: Room, sender: User)
    func banned(server: Server, channel: Channel)
    func inviteOnly(server: Server, channel: Channel)
    
}
