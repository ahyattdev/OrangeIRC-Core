//
//  BlankSocket.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/30/16.
//
//

import Foundation

//
//  Socket.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 6/28/16.
//
//

import Foundation
import Dispatch

public class BlankSocket: NSObject, StreamDelegate {
    
    var inputStream: InputStream
    var outputStream: NSOutputStream
    
    var timeoutTimer: Timer?
    
    var dataToWrite = [Data]()
    
    public init(host: String, port: Int) {
        var inStream: Unmanaged<CFReadStream>?
        var outStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, UInt32(port), &inStream, &outStream)
        
        self.inputStream = inStream!.takeRetainedValue()
        self.outputStream = outStream!.takeRetainedValue()
        
        super.init()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .current(), forMode: .defaultRunLoopMode)
        outputStream.schedule(in: .current(), forMode: .defaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
        
        DispatchQueue.global().async() {
            
        }
    }
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            print("Open completed")
        case Stream.Event.hasBytesAvailable:
            //print("Has bytes available")
            if aStream == self.inputStream {
                var buff = [UInt8]()
                self.inputStream.read(&buff, maxLength: 1024)
                if buff.count > 0 {
                    print(String(bytes: buff, encoding: String.Encoding.utf8))
                }
            }
        case Stream.Event.hasSpaceAvailable:
            break
        case Stream.Event.errorOccurred:
            print("error occured")
        case Stream.Event.endEncountered:
            print("end encountered")
        default: break
        }
    }
    
    public func write(bytes: Data) {
        //dataToWrite.append(bytes)
        let nsData: NSData = bytes
        self.outputStream.write(UnsafePointer<UInt8>(nsData.bytes), maxLength: nsData.length)
    }
    
}
