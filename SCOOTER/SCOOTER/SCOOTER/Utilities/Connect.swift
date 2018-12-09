//
//  Connnection.swift
//  SCOOTER
//
//  Created by RoyIM on 11/6/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import Foundation

var  SCOOTER_IMEI = "";

class Connect: NSObject , StreamDelegate{
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    let maxReadLength = 4096
    
    class func shared() -> Connect {
        if sharedConnect == nil {
            sharedConnect = Connect()
            sharedConnect?.setUpConnection()
//            UserDefaults.standard.set(false, forKey: "TCP_OFF")
        }
//        else {
//
//            if (UserDefaults.standard.bool(forKey:"TCP_OFF")){
//                sharedConnect = Connect()
//                sharedConnect?.setUpConnection()
//                UserDefaults.standard.set(false, forKey: "TCP_OFF")
//            }
//        }
        return sharedConnect!
    }
    
    private static var sharedConnect: Connect?
    
    func setUpConnection() {
        
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(nil, "216.172.179.154" as CFString, 60000, &readStream, &writeStream)
        
        inputStream = readStream?.takeRetainedValue() as InputStream?
        outputStream = writeStream?.takeUnretainedValue() as OutputStream?
        inputStream.delegate = self
        outputStream.delegate = self
        inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        inputStream.open()
        outputStream.open()
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
//        print("ran")
        DispatchQueue.main.async(execute: {
            
            switch eventCode {
            case Stream.Event.hasBytesAvailable:
                print("new message received")
                self.readAvailabeBytes(stream: aStream as! InputStream)
                break
            case Stream.Event.endEncountered:
                print("new message received")
                self.stopSession()
            case Stream.Event.errorOccurred:
                print("error occurred")
            case Stream.Event.hasSpaceAvailable:
                print("has space availabe")
            default:
                print("some other event...")
                break
            }
        })
    }
    
    private func readAvailabeBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity:maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength:maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
            if let message = processingMessageString(buffer:buffer, length:numberOfBytesRead) {
                
                print(message)
                
                NotificationCenter.default.post(
                    name: .MessageReceived,
                    object: nil,
                    userInfo: ["message" : message])
            }
        }
        
    }
    
    
    
    private func processingMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                         length: Int) -> [String]?{
        
        
        let stringVal = String(bytesNoCopy: buffer,
                                       length:length,
                                       encoding:.ascii,
                                       freeWhenDone:true)
        
        let stringArray = stringVal?.components(separatedBy:",")
        
        return stringArray
    }
    
    public func sendMessage(message: String) {
        let data = "\(message)".data(using: .ascii)!
        
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
    
    func stopSession() {
        inputStream.close()
        outputStream.close()
    }
}

extension Notification.Name {
    static let MessageReceived
        = NSNotification.Name("MessageReceived")
}
