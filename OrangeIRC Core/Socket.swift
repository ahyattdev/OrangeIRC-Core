//
//  Socket.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation
import Dispatch

public class Socket: NSObject, StreamDelegate {
    
    var inputStream: InputStream
    var outputStream: NSOutputStream
    
    var delegate: SocketDelegate
    
    var isOpen = false
    
    var timeoutTimer: Timer?
    
    var dataToWrite = [Data]()
    
    public init(host: String, port: Int, delegate: SocketDelegate) {
        self.delegate = delegate
        
        var input: InputStream?
        var output: NSOutputStream?
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &input, outputStream: &output)
        
        inputStream = input!
        outputStream = output!
        
        super.init()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .current(), forMode: .defaultRunLoopMode)
        outputStream.schedule(in: .current(), forMode: .defaultRunLoopMode)
        inputStream.open()
        outputStream.open()
        timeoutTimer = Timer(timeInterval: 30, target: self, selector: #selector(checkTimeout), userInfo: nil, repeats: false)
        RunLoop.current().add(timeoutTimer!, forMode: .defaultRunLoopMode)
        
        RunLoop.current().run()
    }
    
    public func stop() {
        inputStream.close()
        outputStream.close()
        inputStream.remove(from: .current(), forMode: .defaultRunLoopMode)
        outputStream.remove(from: .current(), forMode: .defaultRunLoopMode)
        inputStream.delegate = nil
        outputStream.delegate = nil
        if self.timeoutTimer != nil {
            if self.timeoutTimer!.isValid {
                self.timeoutTimer!.invalidate()
            }
        }
        isOpen = false
    }
    
    public func checkTimeout() {
        if !isOpen {
            delegate.couldNotConnect(socket: self)
        }
    }
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print("\n\n\n\n\nJUST\n\n\n\n\n\n")
        switch eventCode {
        case Stream.Event.openCompleted:
            print("Open completed")
            timeoutTimer?.invalidate()
            self.isOpen = true
            delegate.connectionSucceeded(socket: self)
        case Stream.Event.hasBytesAvailable:
            print("Has bytes available")
            if aStream == self.inputStream {
                var buff = [UInt8]()
                self.inputStream.read(&buff, maxLength: 1024)
                delegate.read(bytes: Data(bytes: buff), on: self)
            }
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
            if aStream == self.outputStream {
                while self.outputStream.hasSpaceAvailable && dataToWrite.count > 0 {
                    let data: NSData = dataToWrite.first!
                    self.outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
                    dataToWrite.removeFirst()
                }
            }
        case Stream.Event.errorOccurred:
            print("error occurred")
            stop()
            delegate.connectionFailed(socket: self)
        case Stream.Event.endEncountered:
            print("end encountered")
            stop()
            delegate.connectionEnded(socket: self)
        default:
            print("Could not handle stream event")
        }
    }
    
    public func write(bytes: Data) {
        dataToWrite.append(bytes)
    }
}
