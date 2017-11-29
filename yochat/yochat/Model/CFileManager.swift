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
    let SUBPATH:String = "/yochat/data/msgs/"
    
    private override init() {
        super.init();
        self.isDocumentExist()
    }
    
    func readLocalMessage(filename:String) -> [MessageModel] {
        let realPath = self.realPath(filename: filename);
        if self.isFileExist(path: realPath) {
            let ary:[MessageModel] = NSKeyedUnarchiver.unarchiveObject(withFile: realPath) as! [MessageModel];
            return ary;
        }
        else {
            return [];
        }
    }
    
    func saveMessageToLocal(filename:String, message:MessageModel!) -> Void {
        let ary:NSMutableArray = NSMutableArray.init(array: self.readLocalMessage(filename: filename));
        ary.add(message);
        NSKeyedArchiver.archiveRootObject(ary.copy(), toFile: self.realPath(filename: filename));
    }
    
    func isFileExist(path:String) -> Bool {
        return self.fm.fileExists(atPath:path);
    }
    
    func isDocumentExist() -> Void {
        let docStr = (self.realPath(filename: "") as NSString).deletingLastPathComponent;
        if fm.fileExists(atPath: docStr) == false {
            try! fm.createDirectory(atPath: docStr, withIntermediateDirectories: true, attributes: nil);
        }
    }
    
    func realPath(filename:String) -> String {
        let baseStr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first;
        return baseStr! + SUBPATH + filename;
    }

}
