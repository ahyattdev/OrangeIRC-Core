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

extension Server{
    
    internal struct NickServ {
        
        private init() { }
        
        static let NICK_REGISTERED = "This nickname is registered."
        static let AUTH_SUCCESS = "You are now identified for"
        static let INVALID_PASSWORD = "Invalid password for"
        static let FAILED_ATTEMPT = "failed login since last login" // There are singular and plural messages
        static let FAILED_ATTEMPTS = "failed logins since last login"
        static let LAST_FAILED_ATTEMPT = "Last failed attempt from:"
        
    }
    
    internal func handleNickServ(_ notice: String) {
        if notice.contains(NickServ.NICK_REGISTERED) {
            if nickservPassword.isEmpty {
                delegate?.nickservPasswordNeeded(self)
            } else {
                sendNickServPassword()
            }
        } else if notice.contains(NickServ.AUTH_SUCCESS) {
            // This is good and no action is necessary
        } else if notice.contains(NickServ.INVALID_PASSWORD) {
            delegate?.nickservPasswordIncorrect(self)
        } else if notice.contains(NickServ.FAILED_ATTEMPT) || notice.contains(NickServ.FAILED_ATTEMPTS) {
            if let spaceRange = notice.range(of: " ")?.lowerBound {
                if let num = Int(notice[notice.index(after: notice.startIndex) ..< notice.index(before: spaceRange)]) {
                    lastSentNickServFailedAttempts = num
                }
            }
        } else if notice.contains(NickServ.LAST_FAILED_ATTEMPT) {
            guard let firstIndicator = notice.range(of: "\u{02}")?.upperBound else {
                return
            }
            
            let afterIndicator = notice[firstIndicator ..< notice.endIndex]
            
            guard let secondIndicator = afterIndicator.range(of: "\u{02}")?.lowerBound else {
                return
            }
            
            let prefixString = afterIndicator[afterIndicator.startIndex ..< secondIndicator]
            
            guard let prefix = Message.Prefix(String(prefixString)) else {
                return
            }
            
            guard let dateStart = notice.range(of: " on ")?.upperBound else {
                return
            }
            
            let date = notice[dateStart ..< notice.index(before: notice.endIndex)]
            
            delegate?.nickservFailedAttemptsWarning(self, count: lastSentNickServFailedAttempts, lastPrefix: prefix.toString(), date: String(date))
        }
        else {
            print("Unknown NickServ message: \(notice)")
        }
    }

}
