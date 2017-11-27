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
    let LOGINURL = "http://192.168.2.200:3000/postlogin"
    
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
            return;
        }
        
        self.processLogin(uid: usrTextField.stringValue, upwd: usrPwdTextField.stringValue);
        
        
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.showTip(msg: "必须登录~   嘿嘿嘿")
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
    
    func closeLoginView() -> Void {
        self.dismissViewController(self);
    }
    func processLogin(uid:String,upwd:String) -> Void {
        let url:URL = URL.init(string: LOGINURL)!;
        let param:Dictionary = ["uid":uid,"upwd":upwd];
        var urlreq = URLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 4);
        urlreq.httpMethod = "POST";
        urlreq.httpBody = try! JSONSerialization.data(withJSONObject: param, options: .prettyPrinted);
        urlreq.setValue("application/json", forHTTPHeaderField: "Content-Type");
        
        let task = URLSession.shared.dataTask(with: urlreq) { (data, response, error) in
            if data != nil {
                let retDic:NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                let isRight = retDic.value(forKey: "retCode") as! String;
                if isRight == "1" {
                    let userInfo = retDic.value(forKey: "USER") as! String
                    let userDic = TypeTransfor.convertToDictionary(text: userInfo);
                    let currUser = UserModel.init(dic: userDic! as NSDictionary);
                    AccountManager.shareInstance.setCurrUser(usr: currUser);
                    self.closeLoginView();
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showTip(msg: "登陆失败！");
                }
            }
        }
        
        task.resume();
    }
}
