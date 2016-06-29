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
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, UInt32(port), &readStream, &writeStream)
        
        inputStream = readStream!.takeUnretainedValue()
        outputStream = writeStream!.takeUnretainedValue()
        
        super.init()
        
        
        
        inputStream.delegate = self
        outputStream.delegate = self
    }
    
    public func start() {
        inputStream.schedule(in: .main(), forMode: .defaultRunLoopMode)
        outputStream.schedule(in: .main(), forMode: .defaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
        
        timeoutTimer = Timer(timeInterval: 30, target: self, selector: #selector(checkTimeout), userInfo: nil, repeats: false)
        
        //self.performSelector(inBackground: #selector(RunLoop.run as (RunLoop) -> () -> Void), with: RunLoop.main())
        
    }
    
    public func checkTimeout() {
        if !isOpen {
            delegate.couldNotConnect(socket: self)
        }
    }
    
    public func stream(aStream: Stream, eventCode: Stream.Event) {
        
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
                // The maximum message length is 512, according to RFC 2812
                self.inputStream.read(&buff, maxLength: 512)
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
            timeoutTimer?.invalidate()
            delegate.connectionEnded(socket: self)
        case Stream.Event.endEncountered:
            print("end encountered")
            aStream.remove(from: .main(), forMode: .defaultRunLoopMode)
            isOpen = false
        default:
            print("Could not handle stream event")
        }
    }
    
    public func write(bytes: Data) {
        dataToWrite.append(bytes)
    }
}
