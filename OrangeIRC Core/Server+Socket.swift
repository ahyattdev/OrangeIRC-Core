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
import CocoaAsyncSocket

extension Server {
    
    /// Must be declared public for `GCDAsyncSocketDelegate`.
    /// You can ignore this 🙂.
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
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
    
    /// Must be declared public for `GCDAsyncSocketDelegate`.
    /// You can ignore this 🙂.
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
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
    
    /// Must be declared public for `GCDAsyncSocketDelegate`.
    /// You can ignore this 🙂.
    @objc(socket:didReadData:withTag:) public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
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
    
    /// Must be declared public for `GCDAsyncSocketDelegate`.
    /// You can ignore this 🙂.
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
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
