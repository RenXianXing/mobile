//
//  connection.swift
//  SCOOTER
//
//  Created by RoyIM on 11/6/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import Foundation

class Connection: NSObject, StreamDelegate {
    var host:String?
    var port:Int?
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    func connect(host: String, port: Int) {
        
        self.host = host
        self.port = port
        
        
        
//        NSStream.getStreamsToHostWithName(host, port: port, inputStream: &inputStream, outputStream: &outputStream)
//
//        if inputStream != nil && outputStream != nil {
//
//            // Set delegate
//            inputStream!.delegate = self
//            outputStream!.delegate = self
//
//            // Schedule
//            inputStream!.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
//            outputStream!.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
//
//            print("Start open()")
//
//            // Open!
//            inputStream!.open()
//            outputStream!.open()
//        }
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if aStream === inputStream {
            switch eventCode {
            case NSStreamEvent.ErrorOccurred:
                print("input: ErrorOccurred: \(aStream.streamError?.description)")
            case NSStreamEvent.OpenCompleted:
                print("input: OpenCompleted")
            case NSStreamEvent.HasBytesAvailable:
                print("input: HasBytesAvailable")
                
                // Here you can `read()` from `inputStream`
                
            default:
                break
            }
        }
        else if aStream === outputStream {
            switch eventCode {
            case NSStreamEvent.ErrorOccurred:
                print("output: ErrorOccurred: \(aStream.streamError?.description)")
            case NSStreamEvent.OpenCompleted:
                print("output: OpenCompleted")
            case NSStreamEvent.HasSpaceAvailable:
                print("output: HasSpaceAvailable")
                
                // Here you can write() to `outputStream`
                
            default:
                break
            }
        }
    }
    
}
