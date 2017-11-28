//
//  Socket.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/19.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa
import SwiftSocket

typealias SockBackItem = (NSDictionary) -> Void

class Socket: NSObject {
    
    var socketClient:TCPClient?
    
    func processClientConfig(adrs:String, port:Int) -> Void {
        if (self.socketClient == nil) {
            socketClient = TCPClient.init(address: adrs, port: Int32(port));
        }
    }
    
    func processConnect(timeout:Int, backItem: @escaping SockBackItem) -> Void {
        DispatchQueue.global(qos: .background).async {
            
            func readmsg() -> NSDictionary? {
                if let data = self.socketClient!.read(4) {
                    if data.count == 4 {
                        let ndata = NSData.init(bytes: data, length: data.count);
                        var len:Int32  = 0;
                        ndata.getBytes(&len, length: data.count);
                        if let buff = self.socketClient!.read(Int(len)) {
                            let msgd = Data.init(bytes: buff, count: buff.count);
                            let msgi = try? JSONSerialization.jsonObject(with: msgd, options: .mutableContainers)
                            return msgi as? NSDictionary;
                        }
                    }
                }
                return nil;
            }
            
            func processMessag(msg:NSDictionary, backItem:SockBackItem) -> Void {
                backItem(msg);

            }
            
            
            let resu:SwiftSocket.Result = self.socketClient!.connect(timeout: timeout)
            switch resu {
                case .success:
                    print("connected")
                    
                    while true {
                        sleep(1);
                        if let msg = readmsg() {
                            DispatchQueue.main.async {
                                processMessag(msg: msg, backItem: backItem)
                            }
                        } else {
                            DispatchQueue.main.async {
                                //                            self.disconnect()
                            }
                            //                        break;
                        }
                    }
                
                case .failure( _):
                    print("connect failed");
                }
        }
    }
    
    func sendMessage(msg:NSDictionary) -> Void {
        self.sendMessageWithHead(msgtosend: msg);
    }
    
    func sendMessageWithHead(msgtosend:NSDictionary) -> Void {
        let msgdata = try? JSONSerialization.data(withJSONObject: msgtosend, options: .prettyPrinted);
        
        var len:Int32 = Int32(msgdata!.count);
        let data:NSMutableData = NSMutableData.init(bytes: &len, length: 4)
        data.append(msgdata!)
        _ = self.socketClient!.send(data: data as Data);
    }
    
}


