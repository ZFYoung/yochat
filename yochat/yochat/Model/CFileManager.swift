//
//  CFileManager.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/20.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

class CFileManager: NSObject {
    
    static let shareInstance = CFileManager()
    let fm = FileManager();
    let SUBPATH:String = "/yochat/data/msgs/messages.dat"
    
    private override init() {
        super.init();
        self.isDocumentExist()
    }
    
    func readLocalMessage() -> [MessageModel] {
        let realPath = self.realPath();
        if self.isFileExist(path: realPath) {
            let ary:[MessageModel] = NSKeyedUnarchiver.unarchiveObject(withFile: realPath) as! [MessageModel];
            return ary;
        }
        else {
            return [];
        }
    }
    
    func saveMessageToLocal(message:MessageModel!) -> Void {
        let ary:NSMutableArray = NSMutableArray.init(array: self.readLocalMessage());
        ary.add(message);
        NSKeyedArchiver.archiveRootObject(ary.copy(), toFile: self.realPath());
    }
    
    func isFileExist(path:String) -> Bool {
        return self.fm.fileExists(atPath:self.realPath());
    }
    
    func isDocumentExist() -> Void {
        let docStr = (self.realPath() as NSString).deletingLastPathComponent;
        if fm.fileExists(atPath: docStr) == false {
            try! fm.createDirectory(atPath: docStr, withIntermediateDirectories: true, attributes: nil);
        }
    }
    
    func realPath() -> String {
        let baseStr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first;
        return baseStr! + SUBPATH;
    }

}
