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
        let message = NSLocalizedString("SERVER_DID_NOT_RESPOND_DESCRIPTION", comment: "").replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        let alert = UIAlertController(title: NSLocalizedString("SERVER_DID_NOT_RESPOND", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
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
        var title = NSLocalizedString("NOTICE_FROM_ON", comment: "")
        title = title.replacingOccurrences(of: "[USERNAME]", with: sender)
        title = title.replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        let alert = UIAlertController(title: title, message: notice, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    func recieved(logEvent: LogEvent, for room: Room) {
        
    }
    
    func recieved(error: String, on server: Server) {
        let fullError = "\(NSLocalizedString("ERROR_DISCONNECT_MESSAGE", comment: "")):\n\n\(error)"
        
        let alert = UIAlertController(title: server.host, message: fullError, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
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
        let nicknameRegistered = NSLocalizedString("NICKNAME_REGISTERED", comment: "Nickname registered")
        let nicknameRegisteredDescription = NSLocalizedString("NICKNAME_REGISTERED_DESCRIPTION", comment: "Provide a password")
        
        let nicknamePasswordAlert = UIAlertController(title: nicknameRegistered, message: nicknameRegisteredDescription, preferredStyle: .alert)
        
        nicknamePasswordAlert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = NSLocalizedString("NICKNAME_PASSWORD", comment: "Nickname Password")
            textField.isSecureTextEntry = true
            self.nickservPasswordField = textField
            textField.delegate = self
        })
        
        let disconnect = NSLocalizedString("DISCONNECT", comment: "Disconnect")
        let disconnectAction = UIAlertAction(title: disconnect, style: .destructive, handler: { (action) in
            server.disconnect()
        })
        nicknamePasswordAlert.addAction(disconnectAction)
        
        let done = NSLocalizedString("AUTHENTICATE", comment: "Done")
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
        let title = NSLocalizedString("NICKNAME_PASSWORD_INCORRECT", comment: "")
        var message = NSLocalizedString("PROVIDE_CORRECT_PASSWORD", comment: "")
        message = message.replacingOccurrences(of: "[NICKNAME]", with: server.nickname)
        message = message.replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = NSLocalizedString("NICKNAME_PASSWORD", comment: "Nickname Password")
            textField.isSecureTextEntry = true
            self.nickservPasswordField = textField
            textField.delegate = self
        })
        
        let disconnect = NSLocalizedString("DISCONNECT", comment: "Disconnect")
        let disconnectAction = UIAlertAction(title: disconnect, style: .destructive, handler: { (action) in
            server.disconnect()
        })
        alert.addAction(disconnectAction)
        
        let authenticate = NSLocalizedString("AUTHENTICATE", comment: "")
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
        
        let title = NSLocalizedString("FAILED_ATTEMPTS_NICKSERV", comment: "")
        var message = NSLocalizedString("FAILED_ATTEMPTS_NICKSERV_MESSAGE", comment: "")
        message = message.replacingOccurrences(of: "[NUM]", with: "\(count)")
        message = message.replacingOccurrences(of: "[MYNICK]", with: server.nickname)
        message = message.replacingOccurrences(of: "[SERVERNAME]", with: server.host)
        message = message.replacingOccurrences(of: "[NICKNAME]", with: nickname)
        message = message.replacingOccurrences(of: "[USERNAME]", with: username)
        message = message.replacingOccurrences(of: "[HOSTNAME]", with: hostname)
        message = message.replacingOccurrences(of: "[DATE]", with: date)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        
        AppDelegate.showAlertGlobally(alert)
    }
    
    func infoWasUpdated(_ user: User) {
        
    }
}
