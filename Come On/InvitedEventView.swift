//
//  InvitedEventView.swift
//  Come On
//
//  Created by Antoine roy on 10/04/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class InvitedEventView: UIView {

    @IBOutlet weak var collectionInvited: UICollectionView!
    @IBOutlet weak var addContact: UIButton!
    
    
    class func instanceFromNib() -> InvitedEventView {
        
        //set array contacts.
        
        return UINib(nibName: "InvitedEventView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! InvitedEventView
        
    }
    
    func initContent() {
        print("init content")
        self.collectionInvited.registerNib(UINib(nibName: "InvitedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "invitedEventCellIdentifier")
        //self.collectionInvited.reloadData()
    }
    
    @IBAction func closeInvitedList(sender: AnyObject) {
        print("hello close")
        UIView.animateWithDuration(0.3, animations: {
            self.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 2)
            }, completion: nil)
    }
    
    
}
