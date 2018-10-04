//
//  FreenodeConnectTest.swift
//  OrangeIRC Core
//
//  Created by Andrew Hyatt on 9/9/18.
//

import XCTest
@testable import OrangeIRCCore

class FreenodeConnectTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testConnect() {
        let server = Server(host: "chat.freenode.net", port: 6667, nickname: "orangeirc", username: "orange", realname: "Orange IRC", encoding: .utf8)
        
        server.delegate = Foo()
        server.connect()
    }

}

class Foo: ServerDelegate {
    func didNotRespond(_ server: Server) { }
    
    func stoppedResponding(_ server: Server) { }
    
    func startedConnecting(_ server: Server) { }
    
    func didDisconnect(_ server: Server) { }
    
    func registeredSuccessfully(_ server: Server) {
        server.join(channel: "#orangeirc")
    }
    
    func received(notice: String, sender: String, on server: Server) { }
    
    func received(logEvent: LogEvent, for room: Room) { }
    
    func received(error: String, on server: Server) { }
    
    func received(topic: String, for room: Room) { }
    
    func finishedReadingUserList(_ room: Room) { }
    
    func motdUpdated(_ server: Server) { }
    
    func nickservPasswordNeeded(_ server: Server) { }
    
    func nickservPasswordIncorrect(_ server: Server) { }
    
    func nickservFailedAttemptsWarning(_ server: Server, count: Int, lastPrefix: String, date: String) { }
    
    func infoWasUpdated(_ user: User) { }
    
    func chanlistUpdated(_ server: Server) { }
    
    func finishedReadingChanlist(_ server: Server) { }
    
    func noSuch(nick: String, _ server: Server) { }
    
    func noSuch(server: String, _ onServer: Server) { }
    
    func noSuch(channel: String, _ server: Server) { }
    
    func cannotSendTo(channel: String, _ server: Server) { }
    
    func tooManyChannels(_ server: Server) { }
    
    func serverPasswordNeeded(_ server: Server) { }
    
    func keyNeeded(channel: Channel, on server: Server) { }
    
    func keyIncorrect(channel: Channel, on server: Server) { }
    
    func kicked(server: Server, room: Room, sender: User) { }
    
    func banned(server: Server, channel: Channel) { }
    
    func inviteOnly(server: Server, channel: Channel) { }
    
}

