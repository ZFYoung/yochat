//
//  MasterViewController.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/19.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa
import Kingfisher

public enum GetFileType:Int {
    case Read
    case Receive
}

class MasterViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate {
    
    @IBOutlet weak var msgTableView: NSTableView!
    @IBOutlet weak var friendTableView: NSTableView!
    @IBOutlet weak var msgTextField: NSTextField!
    @IBOutlet weak var btnSendMsg: NSButton!
    
    var messages:NSMutableArray?
    var friends:NSMutableArray?
    var sClient:Socket?
    var alert:NSAlert?
    
    var currPartner:UserModel? = nil

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
            let TOID = currPartner?.uid;
            let newmsg = MessageModel.init(fromID: FROMID!, toID: TOID!, content: msg, image: "", messageType: .Text)
            
            self.sendMessage(msg: newmsg);
            
            self.messages!.add(newmsg);
            self.appendTableNewMessage(message: newmsg);
            let filename = self.getFileName(type: .Read, msgmodel: nil);
            CFileManager.shareInstance.saveMessageToLocal(filename: filename, message: newmsg);
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
        
        if (AccountManager.shareInstance.getCurrUser() != nil && currPartner != nil) {
            let filename = self.getFileName(type: .Read, msgmodel: nil);
            messages = NSMutableArray.init(array: CFileManager.shareInstance.readLocalMessage(filename: filename));
            self.msgTableView.reloadData();
        }
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
        self.msgTableView.scrollRowToVisible(self.messages!.count);
        self.msgTableView.endUpdates();
    }
    
    func sendMessage(msg:MessageModel) -> Void {
        
        let dic = msg.transToDic()
        self.sClient!.sendMessage(msg: dic);
    }
    
    func processReceiveMsg(msg:NSDictionary) -> Void {

        let msgmodel = MessageModel.init(dic: msg)
        print("RECEIVE DATA FROM: \(msgmodel.fromId)")
        
        if msgmodel.fromId == currPartner?.uid {
            self.messages?.add(msgmodel);
            self.appendTableNewMessage(message: msgmodel);
        }
        let filename = self.getFileName(type: .Receive, msgmodel: msgmodel)
        CFileManager.shareInstance.saveMessageToLocal(filename: filename, message: msgmodel);

    }
    
    func checkIsLogin() -> Void {
        if (AccountManager.shareInstance.isLogin()) {
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "gotoLogin"), sender: self);
        }
    }
    
    func getFileName(type:GetFileType, msgmodel:MessageModel?) -> String {
        switch type {
        case .Read:
            return AccountManager.shareInstance.getCurrUser()!.uid.description + currPartner!.uid.description + "message.dat";
        case .Receive:
            return msgmodel!.toId.description + msgmodel!.fromId.description + "message.dat"
        }
    }
    
    func showTip(msg:String) -> Void {
        if alert == nil {
            alert = NSAlert.init();
            alert!.addButton(withTitle: "OK");
        }
        alert!.messageText = msg;
        alert!.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) in
        })
    }
    
    func getUserInfoWithUid(uid:Int) -> UserModel? {
        for user in friends! {
            let usermo:UserModel = user as! UserModel;
            if usermo.uid == uid {
                return usermo;
            }
        }
        return nil;
    }
    
    /**
     TabelView DataSource Delegate
     */
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView:NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        if (tableColumn!.identifier.rawValue == "MsgColumn") {
            let msg:MessageModel = self.messages!.object(at: row) as! MessageModel;
            
            let fromUser:UserModel = self.getUserInfoWithUid(uid: msg.fromId)!
            let url = URL(string: fromUser.avatar)
            cellView.imageView!.kf.setImage(with: url);
            cellView.textField?.stringValue = msg.content;
            return cellView;
        }
        else if (tableColumn!.identifier.rawValue == "FriendColum"){
            let user:UserModel = self.friends!.object(at: row) as! UserModel;
            let url = URL(string: user.avatar)
            cellView.imageView!.kf.setImage(with: url);
            cellView.textField!.stringValue = user.name;
            return cellView;
        }
        return cellView;
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableView ==  msgTableView ? (messages != nil ? messages!.count : 0) : (friends != nil ? friends!.count : 0);
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if tableView == friendTableView {
            currPartner = (friends!.object(at: row) as! UserModel);
            self.loadLocalMessages()
        }
        
        return true;
    }
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        if friendTableView.selectedRow < 0 {
            self.showTip(msg: "请选择用户~");
            msgTextField.stringValue = "";
            return false;
        }
        return true;
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            self.btnSendMsgClicked(btnSendMsg);
            return true;
        } else {
            return false;
        }
    }
    
}
