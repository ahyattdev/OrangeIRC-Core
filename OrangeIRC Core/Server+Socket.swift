//
//  Server+Socket.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 9/4/16.
//
//

import Foundation
import CocoaAsyncSocket

extension Server {
    
    internal func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        socket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: noTimeout, tag: Tag.Normal)
        print("Connected to host: \(host)")
        // Send the NICK message
        if sock == self.socket {
            if self.password.isEmpty {
                self.sendNickMessage()
            } else {
                self.sendPassMessage()
            }
        }
    }
    
    internal func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        // FIXME: Doesn't call all the delegate functions
        if err != nil {
            let error = err! as NSError
            if let asyncSocketError = GCDAsyncSocketError(rawValue: error.code) {
                switch asyncSocketError {
                case .noError: break
                case .badConfigError: break
                case .badParamError: break
                case .connectTimeoutError: break
                    delegate?.didNotRespond(self)
                case .readTimeoutError:
                    delegate?.stoppedResponding(self)
                case .writeTimeoutError: break
                case .readMaxedOutError: break
                case .closedError: break
                case .otherError: break
                }
            }
        }
        
        
        // We need to wait after QUIT is sent, as things are sent asyncronously
        reset()
    }
    
    @objc(socket:didReadData:withTag:) internal func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let strData = data.subdata(in: (0 ..< data.count))
        
        guard let string = String(bytes: strData, encoding: self.encoding), let message = Message(string) else {
            print("Failed to parse message: \(data)")
            socket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: noTimeout, tag: Tag.Normal)
            return
        }
        
        let entry = ConsoleEntry(text: string, sender: .Server)
        add(consoleEntry: entry)
        
        handle(message: message)
    }
    
    internal func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        switch tag {
        case Tag.Normal:
            break
        case Tag.Pass:
            self.sendNickMessage()
        case Tag.Nick:
            self.sendUserMessage()
        default:
            break
        }
    }
    
}
