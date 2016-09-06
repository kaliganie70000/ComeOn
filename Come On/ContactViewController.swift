//
//  ContactViewController.swift
//  Come On
//
//  Created by Julien Colin on 14/12/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import UIKit
import ObjectMapper

class ContactViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var commonFriendsCollectionView: UICollectionView!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var aboutMe: UITextView!
    @IBOutlet weak var commonFriendsLabel: UILabel!
    
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var removeFriendButton: UIButton!
    @IBOutlet weak var invitationReceivedButton: UIButton!
    @IBOutlet weak var invitationSentButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var localInvitationsForMe: Contact?
    var localInvitations: Contact?
    
    @IBAction func addFriend(sender: AnyObject) {
        ComeOnAPI.sharedInstance.performRequest(UserRoute.CreateInvitation(userId: ComeOnAPI.sharedInstance.auth!.id!, invitedUserId: contact!.id!),
                                                success: { (json, httpCode) -> Void in
                                                    LocalNotifications.notifFriendRequest()
                                                    self.addFriendButton.hidden = true
                                                    self.invitationSentButton.hidden = false
            }, failure: { (json, httpCode) -> Void in })
    }
    
    @IBAction func removeFriend(sender: AnyObject) {
        ComeOnAPI.sharedInstance.performRequest(UserRoute.DeleteContact(meId: ComeOnAPI.sharedInstance.auth!.id!, userId: contact!.id!),
                                                success: { (json, httpCode) -> Void in
                                                    LocalNotifications.notifFriendDeleted()
                                                    self.removeFriendButton.hidden = true
                                                    self.addFriendButton.hidden = false
            }, failure: { (json, httpCode) -> Void in })
    }
    
    @IBAction func invitationReceived(sender: AnyObject) {
        let pseudo = contact.pseudo != nil ? "@\(contact.pseudo!)" : "@SansPseudo"
        
        let alertController = UIAlertController(title: nil, message: "\(pseudo) vous a invité", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .Cancel) { (_) in }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Accepter", style: .Default) { (action) in
            ComeOnAPI.sharedInstance.performRequest(UserRoute.CreateInvitationAccept(meId: ComeOnAPI.sharedInstance.auth!.id!, userId: self.contact!.id!),
                                                    success: { (json, httpCode) -> Void in
                                                        LocalNotifications.notifFriendRequestAccepted()
                                                        self.invitationReceivedButton.hidden = true
                                                        self.removeFriendButton.hidden = false
                }, failure: { (json, httpCode) -> Void in })
        }
        alertController.addAction(OKAction)
        
        let destroyAction = UIAlertAction(title: "Refuser", style: .Destructive) { (action) in
            ComeOnAPI.sharedInstance.performRequest(UserRoute.DeleteContact(meId: ComeOnAPI.sharedInstance.auth!.id!, userId: self.contact!.id!),
                                                    success: { (json, httpCode) -> Void in
                                                        LocalNotifications.notifFriendRequestDenied()
                                                        self.invitationReceivedButton.hidden = true
                                                        self.addFriendButton.hidden = false
                }, failure: { (json, httpCode) -> Void in })
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
        
    }
    
    @IBAction func invitationSent(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Supprimer l'invitation ?", message: "", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Non", style: .Cancel) { (_) in }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Bien-sûr !", style: .Destructive) { (action) in
            ComeOnAPI.sharedInstance.performRequest(UserRoute.DeleteInvitation(meId: ComeOnAPI.sharedInstance.auth!.id!, userId: self.contact!.id!),
                                                    success: { (json, httpCode) -> Void in
                                                        LocalNotifications.notifFriendRequestCancelled()
                                                        self.invitationSentButton.hidden = true
                                                        self.addFriendButton.hidden = false
                }, failure: { (json, httpCode) -> Void in })

        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
        
    }
    
    @IBAction func editProfile(sender: AnyObject) {
        firstnameTextField.enabled = !firstnameTextField.enabled
        lastnameTextField.enabled = !lastnameTextField.enabled
        aboutMe.editable = !aboutMe.editable
        
        if aboutMe.editable == false {
            let params = ["firstname": firstnameTextField.text, "lastname": lastnameTextField.text, "title": aboutMe.text]
            ComeOnAPI.sharedInstance.performRequest(UserRoute.Update(meId: ComeOnAPI.sharedInstance.auth!.id!, params: params),
                                                    success: { (json, httpCode) -> Void in
                                                        self.editButton.setTitle("Edit", forState: UIControlState.Normal)
                }, failure: { (json, httpCode) -> Void in })
        } else {
            editButton.setTitle("Finish", forState: UIControlState.Normal)
        }
        
    }
        
    var contact: ContactItem!
    var contactId: Int?
    
    var commonFriends: [ContactItem] = []
    
    var isMyProfile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        
        if let contactId = contactId {
            fetchCommonFriends(contactId) { self.updateCommonFriends() }
            fetchContact(contactId) {
                self.displayContact()
            }
        } else {
            fetchCommonFriends(contact.id!) { self.updateCommonFriends() }
            displayContact()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            switch id {
            case "showCommonFriend":
                let contactVC = segue.destinationViewController as! ContactViewController
                contactVC.contactId = (sender as! UIView).tag
                break
            default:
                //
                break
            }
        }
    }
    
    func initDisplay() {
        commonFriendsCollectionView.delegate = self
        commonFriendsCollectionView.dataSource = self
        commonFriendsCollectionView.backgroundView = nil
        commonFriendsCollectionView.backgroundColor = UIColor.clearColor()
        
        //        butt.layer.cornerRadius = 5
        //        butt.clipsToBounds = true
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.clearColor(), CustomColors.gradientBlack70().CGColor]
        gradientView.layer.insertSublayer(gradient, above: avatar.layer)
        view.setNeedsLayout()
        
        editButton.hidden = true
        addFriendButton.hidden = true
        removeFriendButton.hidden = true
        invitationSentButton.hidden = true
        invitationReceivedButton.hidden = true
        
        if isMyProfile {
            editButton.hidden = false
            commonFriendsLabel.text = "Friends"
        } else {
            commonFriendsLabel.text = "Common friends"
        }
    }
    
    func fetchContact(id: Int, completion: (() -> Void)? = nil) {
        ComeOnAPI.sharedInstance.performRequest(UserRoute.Read(userId: id), success: { (json, httpCode) -> Void in
            if let c = Mapper<ContactItem>().map(json) {
                self.contact = c
            }
            }, after: {
                ComeOnAPI.sharedInstance.performRequest(UserRoute.ReadInvitationsForMe(userId: ComeOnAPI.sharedInstance.auth!.id!),
                    success: { (json, httpCode) -> Void in
                        if let c = Mapper<Contact>().map(json) {
                            self.localInvitationsForMe = c
                        }
                    }, after: {
                        ComeOnAPI.sharedInstance.performRequest(UserRoute.ReadInvitations(userId: ComeOnAPI.sharedInstance.auth!.id!),
                            success: { (json, httpCode) -> Void in
                                if let c = Mapper<Contact>().map(json) {
                                    self.localInvitations = c
                                }
                        }, after: completion)
                
                })
        })
    }
    
    /// search if we receive an friend request from the displayed contact
    func doIHaveInvitationFromContact() -> Bool {
        if localInvitationsForMe!.results.indexOf({$0.id == contact.id}) != nil {
            return true
        }
        return false
    }
    
    /// search if we receive an friend request from the displayed contact
    func didIInvitatedContact() -> Bool {
        if localInvitations!.results.indexOf({$0.id == contact.id}) != nil {
            return true
        }
        return false
    }
    
    func fetchCommonFriends(id: Int, completion: (() -> Void)? = nil) {
        ComeOnAPI.sharedInstance.performRequest(UserRoute.ReadCommonFriends(meId: ComeOnAPI.sharedInstance.auth!.id!, friendId: id),
                                                success: { (json, httpCode) -> Void in
                                                    if let c = Mapper<CommonFriends>().map(json) {
                                                        self.commonFriends = c.results
                                                    }
            }, after: completion)
    }
    
    func displayContact() {
        if let avatar = contact.extendedPropertyAsObject?.avatar,
            let url = NSURL(string: "http://cdn.comeon.io/\(avatar)") {
            print("Download Started")
            print("lastPathComponent: " + (url.lastPathComponent ?? ""))
            getDataFromUrl(url) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else { return }
                    print(response?.suggestedFilename ?? "")
                    print("Download Finished")
                    self.avatar.image = UIImage(data: data)
                }
            }
        }
        
        if isMyProfile == false {
            if contact.friend == true {
                removeFriendButton.hidden = false
            } else {
                if doIHaveInvitationFromContact() == true {
                    invitationReceivedButton.hidden = false
                } else if didIInvitatedContact() == true {
                    invitationSentButton.hidden = false
                } else {
                    addFriendButton.hidden = false
                }
            }
        }
        if contact.completeName == "" {
            firstnameTextField.text = "@\(contact.pseudo!)"
            lastnameTextField.text = ""
        } else {
            firstnameTextField.text = contact.firstName
            lastnameTextField.text = contact.lastName
        }
        //        if let b = contact.birthday {
        //            nameAgeLabel.text = t + ", " + b
        //        } else {
        //            nameAgeLabel.text = t
        //        }
        aboutMe.text = defaultValueIfEmpty(contact.title, "I was too lazy to write a description... sorry :(")
    }
    
    func defaultValueIfEmpty(a: String?, _ b: String) -> String {
        if let a = a where a.isEmpty == false {
            return a
        }
        return b
    }
    
    func updateCommonFriends() {
        commonFriendsCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commonFriends.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = commonFriendsCollectionView.dequeueReusableCellWithReuseIdentifier("comeonCellIdentifier", forIndexPath: indexPath) as! CommonFriendsCollectionViewCell
        cell.logo.layer.cornerRadius = cell.logo.frame.size.width / 2
        cell.logo.clipsToBounds = true
        
        cell.tag = commonFriends[indexPath.row].id
        cell.label.text = defaultValueIfEmpty(commonFriends[indexPath.row].completeName,
                                              commonFriends[indexPath.row].pseudo!)
        if let avatar = commonFriends[indexPath.row].extendedPropertyAsObject?.avatar,
            let url = NSURL(string: "http://cdn.comeon.io/\(avatar)") {
            getDataFromUrl(url) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else { return }
                    cell.logo.image = UIImage(data: data)
                }
            }
        }
        
        let gestureTap = UITapGestureRecognizer (target: self, action: #selector(ContactViewController.commonContactTapped(_:)))
        cell.addGestureRecognizer(gestureTap)
        return cell
    }
    
    func commonContactTapped(recognizer: UITapGestureRecognizer) {
        performSegueWithIdentifier("showCommonFriend", sender: recognizer.view)
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
}
