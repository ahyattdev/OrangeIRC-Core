//
//  AppDelegate+ServerDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 1/21/17.
//
//

import UIKit
import OrangeIRCCore

extension AppDelegate {
    
    func didNotRespond(_ server: Server) {
        let message = localized("SERVER_DID_NOT_RESPOND_DESCRIPTION").replacingOccurrences(of: "[SERVERNAME]", with: server.displayName)
        let alert = UIAlertController(title: localized("SERVER_DID_NOT_RESPOND"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: nil))
        AppDelegate.showAlertGlobally(alert)
    }
    
    func stoppedResponding(_ server: Server) {
        
    }
    
    func startedConnecting(_ server: Server) {
        
    }
    
    func didDisconnect(_ server: Server) {
        
    }
    
    func registeredSuccessfully(_ server: Server) {
        
    }
    
    func recieved(notice: String, sender: String, on server: Server) {
        var title = localized("NOTICE_FROM_ON")
        title = title.replacingOccurrences(of: "[USERNAME]", with: sender)
        title = title.replacingOccurrences(of: "[SERVERNAME]", with: server.displayName)
        let alert = UIAlertController(title: title, message: notice, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    func recieved(logEvent: LogEvent, for room: Room) {
        
    }
    
    func recieved(error: String, on server: Server) {
        let fullError = "\(localized("ERROR_DISCONNECT_MESSAGE")):\n\n\(error)"
        
        let alert = UIAlertController(title: server.displayName, message: fullError, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: localized("OK"), style: .default, handler: nil)
        alert.addAction(ok)
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    func recieved(topic: String, for room: Room) {
        
    }
    
    func finishedReadingUserList(_ room: Room) {
        
    }
    
    func motdUpdated(_ server: Server) {
        
    }
    
    func nickservPasswordNeeded(_ server: Server) {
        let nicknameRegistered = localized("NICKNAME_REGISTERED")
        let nicknameRegisteredDescription = localized("NICKNAME_REGISTERED_DESCRIPTION")
        
        let nicknamePasswordAlert = UIAlertController(title: nicknameRegistered, message: nicknameRegisteredDescription, preferredStyle: .alert)
        
        nicknamePasswordAlert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = self.localized("NICKNAME_PASSWORD")
            textField.isSecureTextEntry = true
            self.nickservPasswordField = textField
            textField.delegate = self
        })
        
        let disconnect = localized("DISCONNECT")
        let disconnectAction = UIAlertAction(title: disconnect, style: .destructive, handler: { (action) in
            server.disconnect()
        })
        nicknamePasswordAlert.addAction(disconnectAction)
        
        let done = localized("AUTHENTICATE")
        let doneAction = UIAlertAction(title: done, style: .default, handler: { (action) in
            server.nickservPassword = self.nickservPasswordField!.text!
            ServerManager.shared.saveData()
            server.sendNickServPassword()
            
            self.nickservPasswordField?.delegate = nil
            self.nickservPasswordField = nil
            self.doneAction = nil
        })
        doneAction.isEnabled = false
        self.doneAction = doneAction
        
        nicknamePasswordAlert.addAction(doneAction)
        
        AppDelegate.showAlertGlobally(nicknamePasswordAlert)
    }
    
    func nickservPasswordIncorrect(_ server: Server) {
        let title = localized("NICKNAME_PASSWORD_INCORRECT")
        var message = localized("PROVIDE_CORRECT_PASSWORD")
        message = message.replacingOccurrences(of: "[NICKNAME]", with: server.nickname)
        message = message.replacingOccurrences(of: "[SERVERNAME]", with: server.displayName)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = self.localized("NICKNAME_PASSWORD")
            textField.isSecureTextEntry = true
            self.nickservPasswordField = textField
            textField.delegate = self
        })
        
        let disconnect = localized("DISCONNECT")
        let disconnectAction = UIAlertAction(title: disconnect, style: .destructive, handler: { (action) in
            server.disconnect()
        })
        alert.addAction(disconnectAction)
        
        let authenticate = localized("AUTHENTICATE")
        let authAction = UIAlertAction(title: authenticate, style: .default, handler: { (action) in
            server.nickservPassword = self.nickservPasswordField!.text!
            ServerManager.shared.saveData()
            server.sendNickServPassword()
            
            self.nickservPasswordField?.delegate = nil
            self.nickservPasswordField = nil
            self.doneAction = nil
        })
        authAction.isEnabled = false
        doneAction = authAction
        alert.addAction(authAction)
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: Message.Prefix, date: String) {
        guard let nickname = lastPrefix.nickname,
            let username = lastPrefix.user,
            let hostname = lastPrefix.host else {
                return
        }
        
        let title = localized("FAILED_ATTEMPTS_NICKSERV")
        var message = localized("FAILED_ATTEMPTS_NICKSERV_MESSAGE")
        message = message.replacingOccurrences(of: "[NUM]", with: "\(count)")
        message = message.replacingOccurrences(of: "[MYNICK]", with: server.nickname)
        message = message.replacingOccurrences(of: "[SERVERNAME]", with: server.displayName)
        message = message.replacingOccurrences(of: "[NICKNAME]", with: nickname)
        message = message.replacingOccurrences(of: "[USERNAME]", with: username)
        message = message.replacingOccurrences(of: "[HOSTNAME]", with: hostname)
        message = message.replacingOccurrences(of: "[DATE]", with: date)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    func infoWasUpdated(_ user: User) {
        
    }
    
    func chanlistUpdated(_ server: Server) {
        
    }
    
    func finishedReadingChanlist(_ server: Server) {
        
    }
    
    public func noSuch(nick: String, _ server: Server) {
        let message = localized("NO_SUCH_NICK_OR_CHAN_MESSAGE").replacingOccurrences(of: "@NICK@", with: nick)
        
        let alert = UIAlertController(title: localized("NO_SUCH_NICK_OR_CHAN"), message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    public func noSuch(server: String, _ onServer: Server) {
        let message = localized("NO_SUCH_SERVER_MESSAGE").replacingOccurrences(of: "@SERVER@", with: server)
        
        let alert = UIAlertController(title: localized("NO_SUCH_SERVER"), message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    public func noSuch(channel: String, _ server: Server) {
        let message = localized("NO_SUCH_CHANNEL_MESSAGE").replacingOccurrences(of: "@CHANNEL@", with: channel)
        
        let alert = UIAlertController(title: localized("NO_SUCH_CHANNEL"), message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    public func cannotSendTo(channel: String, _ server: Server) {
        let message = localized("CANNOT_SEND_TO_CHANNEL_MESSAGE").replacingOccurrences(of: "@CHANNEL@", with: channel)
        
        let alert = UIAlertController(title: localized("CANNOT_SEND_TO_CHANNEL"), message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    public func tooManyChannels(_ server: Server) {
        let alert = UIAlertController(title: localized("TOO_MANY_CHANNELS"), message: localized("TOO_MANY_CHANNELS_MESSAGE"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: localized("OK"), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    public func serverPaswordNeeed(_ server: Server) {
        let alert = ServerPasswordAlert(server)
        AppDelegate.showAlertGlobally(alert)
    }
    
}
