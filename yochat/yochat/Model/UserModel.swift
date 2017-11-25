//
//  UserModel.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/22.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

class UserModel: NSObject {
        
    var uid:Int!;
    var avatar:String!;
    var name:String!;
    var password:String!;
    
    init(uid:Int, name:String, avatar:String, password:String) {
        self.uid = uid;
        self.name = name;
        self.password = password;
        self.avatar = avatar;
    }
    
    init(dic:NSDictionary) {
        self.uid = dic.value(forKey: "UID") as! Int;
        self.name = dic.value(forKey: "NAME") as! String;
        self.password = dic.value(forKey: "PASSWORD") as! String;
        self.avatar = dic.value(forKey: "AVATAR") as! String;
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.uid = aDecoder.decodeInteger(forKey: "S_UID");
        self.name = aDecoder.decodeObject(forKey: "S_NAME") as! String;
        self.password = aDecoder.decodeObject(forKey: "S_PASSWORD") as! String;
        self.avatar = aDecoder.decodeObject(forKey: "S_AVATAR") as! String;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Int(self.uid), forKey: "S_UID");
        aCoder.encode(self.name, forKey: "S_NAME");
        aCoder.encode(self.password, forKey: "S_PASSWORD");
        aCoder.encode(self.avatar, forKey: "S_AVATAR");
    }
}
