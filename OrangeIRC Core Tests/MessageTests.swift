//
//  CommandTests.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 12/25/16.
//
//

import XCTest
import OrangeIRCCore

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
