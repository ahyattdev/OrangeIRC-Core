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
    func identifiedSucessfully(server: Server)
    func authenticatedSucessfully(server: Server)
    
}
