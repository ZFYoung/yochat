//
//  MasterViewController.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/19.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa
import Kingfisher

class MasterViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate {
    
    @IBOutlet weak var msgTableView: NSTableView!
    @IBOutlet weak var friendTableView: NSTableView!
    @IBOutlet weak var msgTextField: NSTextField!
    @IBOutlet weak var btnSendMsg: NSButton!
    
    var messages:NSMutableArray?
    var friends:NSMutableArray?
    var sClient:Socket?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages = NSMutableArray.init();
        friends = NSMutableArray.init();
        self.processClient();
        self.loadLocalMessages();
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRemoteFriendList), name: NSNotification.Name.init("LOGINSUCCESSFUL"), object: nil);
        
    }
    
    override func viewWillAppear() {
        self.checkIsLogin();
        
    }
    
    /**
     Button Actions
     */
    @IBAction func btnSendMsgClicked(_ sender: Any) {
        let msg:String = msgTextField.stringValue;
        if msg.count > 0 {
            
            let FROMID = AccountManager.shareInstance.getCurrUser()?.uid;
            let TOID = FROMID == 1 ? 2 : 1;
            let newmsg = MessageModel.init(fromID: FROMID!, toID: TOID, content: msg, image: "", messageType: .Text)
            
            self.sendMessage(msg: newmsg);
            self.save_add_appendNewMessage(msgmodel: newmsg);
        }
        
        self.msgTextField.stringValue = "";
    }
    
    
    /**
     Private
     */
    func processClient() -> Void {
        if sClient == nil {
            sClient = Socket();
            sClient?.processClientConfig(adrs: "192.168.2.200", port: 2345);
        }
        let _ = sClient!.processConnect(timeout: 4) { (dictionary) in
            self.processReceiveMsg(msg: dictionary);
        }
    }
    
    func loadLocalMessages() -> Void {
        messages = NSMutableArray.init(array: CFileManager.shareInstance.readLocalMessage());
        self.msgTableView.reloadData();
    }
    
    @objc func loadRemoteFriendList() -> Void {
        let friurl = "http://192.168.2.200:3000/getallusers"
        NetWorkManager.requestWithUrl(urlStr: friurl, method: "GET", param: nil, timeout: 4) { (data, respomse, error) in
            if data != nil {
                let retDic:NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                let isRight = retDic.value(forKey: "retCode") as! String;
                if isRight == "1" {
                    let userInfo = retDic.value(forKey: "ALLUSERS") as! String
                    self.friends!.removeAllObjects();
                    let alluser:NSArray = TypeTransfor.convertToDictionary(text: userInfo) as! NSArray;
                    for userDic in alluser {
                        let currUser = UserModel.init(dic: userDic as! NSDictionary);
                        self.friends!.add(currUser);
                        DispatchQueue.main.async {
                            self.friendTableView.reloadData();
                        }
                    }
                }
            }
        }
    }
    
    func appendTableNewMessage(message:MessageModel) -> Void {
        self.msgTableView.beginUpdates();
        self.msgTableView.insertRows(at: IndexSet.init(integer: self.messages!.count-1), withAnimation: .effectGap);
        self.msgTableView.scrollRowToVisible(self.messages!.count-1);
        self.msgTableView.endUpdates();
    }
    
    func save_add_appendNewMessage(msgmodel:MessageModel) -> Void {
        
        self.messages?.add(msgmodel);
        self.appendTableNewMessage(message: msgmodel);
        CFileManager.shareInstance.saveMessageToLocal(message: msgmodel);

    }
    
    func sendMessage(msg:MessageModel) -> Void {
        
        let dic = msg.transToDic()
        self.sClient!.sendMessage(msg: dic);
    }
    
    func processReceiveMsg(msg:NSDictionary) -> Void {

        let msgmodel = MessageModel.init(dic: msg)
        print("RECEIVE DATA FROM: \(msgmodel.fromId)")
        self.save_add_appendNewMessage(msgmodel: msgmodel);
    }
    
    func checkIsLogin() -> Void {
        if (AccountManager.shareInstance.isLogin()) {
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "gotoLogin"), sender: self);
        }
    }
    
    /**
     TabelView DataSource Delegate
     */
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView:NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        if (tableColumn!.identifier.rawValue == "MsgColumn") {
            let msg:MessageModel = self.messages!.object(at: row) as! MessageModel;
            cellView.imageView?.image = NSImage.init(named: NSImage.Name(rawValue: "bugimage"));
            cellView.textField?.stringValue = msg.content;
            return cellView;
        }
        else if (tableColumn!.identifier.rawValue == "FriendColum"){
            let user:UserModel = self.friends!.object(at: row) as! UserModel;
            let url = URL(string: user.avatar)
            cellView.imageView!.kf.setImage(with: url)
            cellView.textField!.stringValue = user.name;
            return cellView;
        }
        return cellView;
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableView ==  msgTableView ? (messages != nil ? messages!.count : 0) : (friends != nil ? friends!.count : 0);
    }
    
}
