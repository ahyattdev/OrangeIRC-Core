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

import XCTest
@testable import OrangeIRCCore

class MessageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyMessage() {
        let message = Message("")
        assert(message == nil)
    }
    
    func testJustCRLF() {
        let message = Message("\r\n")
        assert(message == nil)
    }
    
    func testSingleString() {
        let message = Message("assfdfdfdfd")
        assert(message == nil)
    }
    
    func testIRCv3Tags() {
        guard let message = Message("@badges=staff/1,bits/1000;bits=100;color=;display-name=TWITCH_UserNaME;emotes=;id=b34ccfc7-4977-403a-8a94-33c6bac34fb8;mod=0;room-id=1337;subscriber=0;turbo=1;user-id=1337;user-type=staff :twitch_username!twitch_username@twitch_username.tmi.twitch.tv PRIVMSG #channel :cheer100") else {
            XCTFail()
            return
        }
        
        // Check a few notable tags
        assert(message.tags[0].key == "badges" && message.tags[0].value != nil && message.tags[0].value! == "staff/1,bits/1000" && message.tags[0].vendor == nil)
        assert(message.tags[1].key == "bits" && message.tags[1].value != nil && message.tags[1].value! == "100" && message.tags[1].vendor == nil)
        assert(message.tags[2].key == "color" && message.tags[2].value == nil && message.tags[2].vendor == nil)
        
        // Check the prefix
        assert(message.prefix != nil)
        assert(message.prefix!.nickname == "twitch_username" && message.prefix!.user == "twitch_username" && message.prefix!.host == "twitch_username.tmi.twitch.tv")
        
        // Check the command, target, and parameters
        assert(message.command == "PRIVMSG" && message.target.count == 1 && message.target[0] == "#channel" && message.parameters == "cheer100")
    }
    
}
