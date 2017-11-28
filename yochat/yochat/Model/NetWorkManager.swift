//
//  NetWorkManager.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/28.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

typealias ResponseItem = (Data?, URLResponse?, Error?) -> Void

class NetWorkManager: NSObject {

    
    class func requestWithUrl(urlStr:String, method:String, param:[String:Any]?, timeout:TimeInterval = 4, responseItem: @escaping ResponseItem) -> Void {
        
        let url:URL = URL.init(string: urlStr)!;
        var urlreq = URLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout);
        urlreq.httpMethod = method;
        if param != nil {
            urlreq.httpBody = try! JSONSerialization.data(withJSONObject: param!, options: .prettyPrinted);
        }
        urlreq.setValue("application/json", forHTTPHeaderField: "Content-Type");
        
        let task = URLSession.shared.dataTask(with: urlreq) { (data, response, error) in
            responseItem(data, response, error);
        }
        task.resume();
    }
}
