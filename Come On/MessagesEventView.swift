//
//  MessagesEventView.swift
//  Come On
//
//  Created by Antoine roy on 11/04/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class MessagesEventView: UIView {

    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var writteBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var fieldMessage: UITextView!
    var idEvent: Int?
    
    class func instanceFromNib() -> MessagesEventView {
        
        //set array messages.
        
        return UINib(nibName: "MessagesEventView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MessagesEventView
        
    }

    func initContent() {
        self.sendBtn.hidden = true
        self.fieldMessage.hidden = true
        self.cancelBtn.hidden = true

        messagesTable.registerNib(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "MessagesEventCellIdentifier")
    }
    
    @IBAction func closeView(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 2)
            }, completion: nil)
    }

    @IBAction func ShowWrittingMessage(sender: AnyObject) {
        self.fieldMessage.hidden = false
        self.writteBtn.hidden = true
        self.sendBtn.hidden = false
        self.cancelBtn.hidden = false
    }
    
    @IBAction func SendMessage(sender: AnyObject) {
        if fieldMessage.text != "" {
            ComeOnAPI.sharedInstance.performRequest(EventRoute.SendMessage(id: idEvent!, message: fieldMessage.text),
                                                    success: { (json, httpCode) -> Void in
                                                        
                },
                                                    failure: { (json, httpCode) -> Void in
                                                        print("error post message!")
            })
        }
        self.sendBtn.hidden = true
        self.cancelBtn.hidden = true
        self.fieldMessage.hidden = true
        self.writteBtn.hidden = false

    }
    
    @IBAction func CancelMessage(sender: AnyObject) {
        self.sendBtn.hidden = true
        self.cancelBtn.hidden = true
        self.fieldMessage.hidden = true
        self.writteBtn.hidden = false

    }
    
}
