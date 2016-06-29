//
//  SocketDelegate.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation

public protocol SocketDelegate {
    
    func couldNotConnect(socket: Socket)
    func connectionSucceeded(socket: Socket)
    func connectionFailed(socket: Socket)
    func connectionEnded(socket: Socket)
    
    func read(bytes: Data, on socket: Socket)
    
}
