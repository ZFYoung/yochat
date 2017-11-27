//
//  TypeTransfor.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/27.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

class TypeTransfor: NSObject {

    
    
    class func STRTOINT(str:String) -> Int {
        let nsstr = str as NSString;
        return nsstr.integerValue;
    }
    
    class func INTTOSTR(iit:Int) -> String {
        let nsstr = NSString.init(format: "%d", iit);
        return nsstr as String;
    }
    
    class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
