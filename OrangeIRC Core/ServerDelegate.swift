//
//  ServerDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation

public protocol ServerDelegate {
    
    func didNotRespond(server: Server)
    func stoppedResponding(server: Server)
    
    func connectedSucessfully(server: Server)
    
    func didRegister(server: Server)
    
    func recieved(notice: String, server: Server)
    
    func finishedReadingUserList(room: Room)
    func recievedTopic(room: Room)
    
    func joined(room: Room)
    
    func startedConnecting(server: Server)
    
    func finishedReadingMOTD(server: Server)
    
}
