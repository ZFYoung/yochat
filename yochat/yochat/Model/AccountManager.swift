//
//  AccountManager.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/25.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

class AccountManager: NSObject {
    
    private var currUser:UserModel? = nil
    
    static let shareInstance = AccountManager()
    
    func setCurrUser(usr:UserModel!) -> Void {
        self.currUser = usr;
    }
    
    func isLogin() -> Bool {
        return currUser==nil
    }

}
