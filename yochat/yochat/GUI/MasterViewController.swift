//
//  MasterViewController.swift
//  yochat
//
//  Created by ZFYoung on 2017/11/19.
//  Copyright © 2017年 ZFYoung. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate {
    
    @IBOutlet weak var msgTableView: NSTableView!
    @IBOutlet weak var msgTextField: NSTextField!
    @IBOutlet weak var btnSendMsg: NSButton!
    var FROMID = 1;
    var TOID = 2;
    
    var messages:NSMutableArray?
    var sClient:Socket?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages = NSMutableArray.init();
        self.processClient();
        self.loadLocalMessages();
        
    }
    
    override func viewWillAppear() {
//        self.checkIsLogin();
    }
    
    /**
     Button Actions
     */
    @IBAction func btnSendMsgClicked(_ sender: Any) {
        let msg:String = msgTextField.stringValue;
        if msg.count > 0 {
            let newmsg = MessageModel.init(fromID: FROMID, toID: TOID, content: msg, image: "", messageType: .Text)
            
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
        return cellView;
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages != nil ? messages!.count : 0;
    }
    
}
