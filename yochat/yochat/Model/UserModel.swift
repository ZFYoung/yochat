//
//  UserModel.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/22.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

class UserModel: NSObject,NSCoding {
        
    var uid:String!;
    var avatar:String!;
    var name:String!;
    var password:String!;
    var oneword:String!;
    
    init(uid:String, name:String, avatar:String, password:String, oneword:String) {
        self.uid = uid;
        self.name = name;
        self.password = password;
        self.avatar = avatar;
        self.oneword = oneword;
    }
    
    init(dic:NSDictionary) {
        self.uid = dic.value(forKey: "_id") as! String;
        self.name = dic.value(forKey: "username") as! String;
        if let pwd = dic.value(forKey: "userpwd") {
            self.password = pwd as! String;
        }
        if let avatar = dic.value(forKey: "useravatar") {
            self.avatar = avatar as! String;
        }
        if let oneword = dic.value(forKey: "useroneword") {
            self.oneword = oneword as! String;
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.uid = aDecoder.decodeObject(forKey: "S_UID") as! String;
        self.name = aDecoder.decodeObject(forKey: "S_NAME") as! String;
        self.password = aDecoder.decodeObject(forKey: "S_PASSWORD") as! String;
        self.avatar = aDecoder.decodeObject(forKey: "S_AVATAR") as! String;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.uid, forKey: "S_UID");
        aCoder.encode(self.name, forKey: "S_NAME");
        aCoder.encode(self.password, forKey: "S_PASSWORD");
        aCoder.encode(self.avatar, forKey: "S_AVATAR");
    }
}
