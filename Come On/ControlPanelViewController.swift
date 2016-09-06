//
//  ProfileViewController.swift
//  Come On
//
//  Created by Julien Colin on 20/04/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class ControlPanelViewController: UIViewController, GridComponent {

    var rootVC: HomeViewController!
    
    /// Fired when comeOn button pressd
    @IBAction func logOut(sender: AnyObject) {
        rootVC.logOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func goToMyProfile(sender: AnyObject) {
        let contactsStoryboard = UIStoryboard(name: "Contacts", bundle: nil)
        let contactVc = contactsStoryboard.instantiateViewControllerWithIdentifier("ContactViewControllerId") as! ContactViewController
        contactVc.contactId = ComeOnAPI.sharedInstance.auth!.id!
        contactVc.isMyProfile = true
        presentViewController(contactVc, animated: true, completion: nil)
    }
    
    func didScrollToViewController(scrollView: UIScrollView) {}
}
