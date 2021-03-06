
//
//  MessageModel.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/20.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

public enum MessageType:Int {
    case Text
    case Image
    case Audio
}

class MessageModel: NSObject,NSCoding {
    
    var fromId:String!;
    var toId:String!;
    var content:String!;
    var imageUrl:String!;
    var time:Int!;
    var msgType:MessageType!;
    
    
    init(fromID:String, toID:String, content:String, image:String, messageType:MessageType) {
        self.fromId = fromID;
        self.toId = toID;
        self.content = content;
        self.imageUrl = image;
        self.msgType = messageType;
        self.time = Int(Date.timeIntervalSinceReferenceDate);
    }
    
    init(dic:NSDictionary) {
        self.fromId = dic.value(forKey: "FROMID") as! String;
        self.toId = dic.value(forKey: "TOID") as! String;
        self.content = dic.value(forKey: "CONTENT") as! String;
        self.imageUrl = dic.value(forKey: "IMAGEURL") as! String;
        self.msgType = MessageType(rawValue: TypeTransfor.STRTOINT(str: dic.value(forKey: "MESSAGETYPE") as! String));
        self.time = TypeTransfor.STRTOINT(str: dic.value(forKey: "TIME") as! String);
    }
    
    func transToDic() -> NSDictionary {
        let retDic = NSMutableDictionary.init();
        
        retDic.setObject(self.fromId, forKey: "FROMID" as NSCopying);
        retDic.setObject(self.toId, forKey: "TOID" as NSCopying);
        retDic.setObject(self.content, forKey: "CONTENT" as NSCopying);
        retDic.setObject(self.imageUrl, forKey: "IMAGEURL" as NSCopying);
        retDic.setObject(TypeTransfor.INTTOSTR(iit: self.msgType.rawValue), forKey: "MESSAGETYPE" as NSCopying);
        retDic.setObject(TypeTransfor.INTTOSTR(iit: self.time), forKey: "TIME" as NSCopying);

        return retDic;
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.fromId = aDecoder.decodeObject(forKey: "S_FROMID") as! String;
        self.toId = aDecoder.decodeObject(forKey: "S_TOID") as! String;
        self.content = aDecoder.decodeObject(forKey: "S_CONTENT") as! String;
        self.imageUrl = aDecoder.decodeObject(forKey: "S_IMAGEURL") as! String;
        self.msgType = MessageType(rawValue: aDecoder.decodeInteger(forKey: "S_MSGTYPE"));
        self.time = aDecoder.decodeInteger(forKey: "S_TIME");
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.fromId, forKey: "S_FROMID");
        aCoder.encode(self.toId, forKey: "S_TOID");
        aCoder.encode(self.content, forKey: "S_CONTENT");
        aCoder.encode(self.imageUrl, forKey: "S_IMAGEURL");
        aCoder.encode(self.msgType.rawValue, forKey: "S_MSGTYPE");
        aCoder.encode(Int(self.time), forKey: "S_TIME");
    }

}
