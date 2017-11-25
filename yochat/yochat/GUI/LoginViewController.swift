//
//  LoginViewController.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/25.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    @IBOutlet weak var usrTextField: NSTextField!
    @IBOutlet weak var usrPwdTextField: NSSecureTextField!
    
    @IBOutlet weak var btnLogin: NSButton!
    @IBOutlet weak var btnCancel: NSButton!
    
    var alert:NSAlert?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    /**
     IBActions
     */
    @IBAction func btnLoginClicked(_ sender: Any) {
        
        if usrTextField.stringValue.count <= 0 || usrPwdTextField.stringValue.count <= 0 {
            self.showTip(msg: "请输入正确的账号和密码");
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.showTip(msg: "必须登录~   嘿嘿嘿")
//        self.dismissViewController(self);
    }
    
    
    /**
     Private
     */
    
    func showTip(msg:String) -> Void {
        if alert == nil {
            alert = NSAlert.init();
            alert!.addButton(withTitle: "OK");
        }
        alert!.messageText = msg;
        alert!.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) in
            
        })
    }
}
