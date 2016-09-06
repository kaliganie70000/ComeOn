//
//  ManageEventViewController.swift
//  Come On
//
//  Created by Antoine roy on 22/03/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import XLActionController

class ManageEventViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageEvent: UIImageView!
    //@IBOutlet weak var titleEvent: UILabel!
    @IBOutlet weak var titleEvent: UITextField!
    
    @IBOutlet weak var nbParticipant: UILabel!
    @IBOutlet weak var nbMessages: UILabel!
    @IBOutlet weak var eventCheckBox: UIButton!
    //@IBOutlet weak var descriptionEvent: UITextField!
    @IBOutlet weak var descriptionEvent: UITextView!
    
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var modifyBtn: UIButton!
    @IBOutlet weak var changePictureBtn: UIButton!
    var imagePicker = UIImagePickerController()
    
    var eventItem: EventItem?
    var dateSet: String?
    var descriptionSet: String?
    
    var cell: EventTableViewCell?
    
    var actionController = TweetbotActionController()
    let idUser: Int = (ComeOnAPI.sharedInstance.auth?.id)!
    let listInvited: InvitedEventView = InvitedEventView.instanceFromNib()
    let listMessages: MessagesEventView = MessagesEventView.instanceFromNib()
    
    var stateBtn: Int = 0

    var date = NSDate() {
        didSet {
            let diffTime = Int(date.timeIntervalSinceDate(NSDate()))
            switch diffTime {
            case 0...59:
                dateField.text = "Maintenant"
                break
            case 60...699:
                dateField.text = "Dans 10 minutes"
                break
            case 700...1899:
                dateField.text = "Dans 30 minutes"
                break
            case 1900...3700:
                dateField.text = "Dans 1 heure"
                break
            case 3701...88400:
                dateField.text = "Demain"
                break
            default:
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "dd-MM-yyyy HH:mm"
                dateField.text = dateFormat.stringFromDate(date)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modifyBtn.hidden = true
        eventCheckBox.hidden = false
        //listInvited.addContact.hidden = true

        
        if idUser == eventItem?.ownerId {
            modifyBtn.hidden = false
            eventCheckBox.hidden = true
        }
        
        getEvent()
        getMedias()
        getListParticipant()
        
        dateField.enabled = false
        //descriptionEvent.enabled = false
        descriptionEvent.editable = false
        titleEvent.enabled = false
        
        titleEvent.text = eventItem?.title
        descriptionEvent.delegate = self
        dateField.delegate = self
        titleEvent.delegate = self
        
        //self.getMedias()
        listInvited.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 2)
        self.view.addSubview(listInvited)
        self.view.bringSubviewToFront(listInvited)
        listInvited.collectionInvited.delegate = self
        listInvited.collectionInvited.dataSource = self
        listInvited.initContent()
        listInvited.addContact.addTarget(self, action: #selector(ManageEventViewController.showAddContact), forControlEvents: UIControlEvents.TouchDown)
        
        
        listMessages.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 2)
        self.view.addSubview(listMessages)
        self.view.bringSubviewToFront(listInvited)
        listMessages.messagesTable.delegate = self
        listMessages.messagesTable.dataSource = self
        listMessages.initContent()
        
        //getListParticipant()
        changePictureBtn.hidden = true
        
        dateField.text = dateSet
        descriptionEvent.text = descriptionSet
        
        getMessages()
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showEventDetail":
                let eventDetailVC = segue.destinationViewController as! EventDetailViewController
                guard let eventItem = eventItem else {
                    assert(false, "No event id ?")
                }
                eventDetailVC.eventItem = eventItem

                break
            case "changeDateIdentifier":
                let changeEventDateAndtimeVC = segue.destinationViewController as! NewEventDateAndTimeViewController
                changeEventDateAndtimeVC.parentVC = self
                changeEventDateAndtimeVC.typeDate = 2
                break
            default:
                assert(false, "Segue should be prepared")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ManageEventViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ManageEventViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("bonjour")
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectMake(0, -keyboardSize!.height, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("au revoir")
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            }, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func changeAnswerEvent(sender: AnyObject) {
        if (stateBtn == 0) {
            eventCheckBox.setBackgroundImage(UIImage(named: "checkBoxValide"), forState: .Normal)
            acceptInvitation()
            stateBtn = 1
        } else if (stateBtn == 1) {
            eventCheckBox.setBackgroundImage(UIImage(named: "checkBoxInvalide"), forState: .Normal)
            rejectInvitation()
            stateBtn = 2
        } else if (stateBtn == 2) {
            eventCheckBox.setBackgroundImage(UIImage(named: "checkBoxValide"), forState: .Normal)
            acceptInvitation()
            stateBtn = 1
        }
    }
    
    func getMessages() {
        
        self.listMessages.idEvent = eventItem!.id
        
        ComeOnAPI.sharedInstance.performRequest(EventRoute.GetMessages(id: eventItem!.id!),
                                                success: { (json, httpCode) -> Void in
                                                    print("----->messages received:\n\(json)")
            },
                                                failure: { (json, httpCode) -> Void in
                                                    print("----->error get messages")
        })

    }

    func acceptInvitation() {
        ComeOnAPI.sharedInstance.performRequest(EventRoute.AcceptInvitation(id: eventItem!.id!),
            success: { (json, httpCode) -> Void in
                print("event : \(self.eventItem!.id!) accepted")
            },
            failure: { (json, httpCode) -> Void in
                print("failure for event \(self.eventItem!.id!)")
        })
    }
    
    func rejectInvitation() {
        ComeOnAPI.sharedInstance.performRequest(EventRoute.RejectInvitation(id: eventItem!.id!),
            success: { (json, httpCode) -> Void in
                print("event : \(self.eventItem!.id!) rejected")
            },
            failure: { (json, httpCode) -> Void in
                print("failure for event \(self.eventItem!.id!)")
        })
    }
    
    func getListParticipant() {
        print("perform get list participant")
        ComeOnAPI.sharedInstance.performRequest(EventRoute.ListParticipant(id: eventItem!.id!),
            success: { (json, httpCode) -> Void in
                guard let eventParticipants = Mapper<EventParticipants>().map(json) else {
                    return
                }
                self.eventItem?.participants = eventParticipants.results
                self.listInvited.collectionInvited.reloadData()
                print("get list participant successed: \(json)")
                self.nbParticipant.text = "\((self.eventItem?.participants?.count)!)"
            },
            failure: { (json, httpCode) -> Void in
                print("get list participant failed")
        })
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func getEvent() {
        print("perform get Event")
        ComeOnAPI.sharedInstance.performRequest(EventRoute.ReadEvent(id: eventItem!.id!),
            success: { (json, httpCode) -> Void in
        
                let result = Mapper<EventSingle>().map(json)
                
                
                self.titleEvent.text = result?.title
                self.dateField.text = result?.str_date
                self.descriptionEvent.text = result?.description
                //ajouter check box state
                
            }, failure: { (json, httpCode) -> Void in
            
            
            })
    }
    
    func getMedias() {
        print("perform get medias")
        ComeOnAPI.sharedInstance.performRequest(EventRoute.GetMediasEvent(id: eventItem!.id!),
            success: { (json, httpCode) -> Void in
                
                guard let eventMedia = Mapper<EventImage>().map(json) else {
                    return
                }
                
                if eventMedia.results?.count > 0 {
                    print("get medias successed: \(json)")
                    print("resultat path: \(eventMedia.results![0].toString())")
                    
                    let url = NSURL(string: "http://cdn.comeon.io/\(eventMedia.results![0].path!)")
                    let _ = self.getDataFromUrl(url!, completion: { (data, response, error)  in
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            guard let data = data where error == nil else { return }
                            self.imageEvent!.image = UIImage(data: data)
                        }
                    })
                }
                
                
            },
            failure: { (json, httpCode) -> Void in
                print("get medias failed")
        })
    }
    
    
    func uploadFileData(imageData:NSData) -> NSData {
        
        let boundaryConstant = "myRandomBoundary12345";
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        return uploadData
    }
    
    func setMedia() {
        print("perform set media")
        let imageData = UIImagePNGRepresentation(imageEvent.image!)
        
        //let data = uploadFileData(imageData!)
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        //print("data media: \(imageData)")
        //let strData = data.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
       

        
        ComeOnAPI.sharedInstance.performFormDataRequest(EventRoute.SetMediaEvent(id: eventItem!.id!), dataImage: imageData!,
                                                        
                                                        success: { Void in
                                                            print("success perform form data request")
            }, failure: { Void in
        
                print("fail perform form data request")
        })
                                                    
        
        /*ComeOnAPI.sharedInstance.performRequest(EventRoute.SetMediaEvent(id: eventItem!.id!, param: requestBodyData, contentType: contentType),
            success: { Void in
                print("set medias successed")
                
            },
            failure: { Void in
                print("set medias failed")
        })*/
        
        
        
    
        
    }
    
    func performModifyEvent() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let changeEvent: [String: AnyObject] = [
            "title": titleEvent.text!,
            //"date_start": formatter.stringFromDate(date),
            "date_start": dateField.text!,
            //            "date_end": "",x
            "latitude": eventItem!.latitude!,
            "longitude": eventItem!.longitude!,
            "description" : descriptionEvent.text!]
        
        ComeOnAPI.sharedInstance.performRequest(EventRoute.UpdateEvent(id: self.eventItem!.id!, params: changeEvent),
            success: { (json, httpCode) -> Void in
                                                    
            print("evenement changed")
            self.cell?.labelTitle.text = self.titleEvent.text
            self.cell?.labelTime.text = self.dateField.text
                
            let alertController = UIAlertController(title: "Succès", message: "L'événement a été modifié.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
                                                    
                                                    
            }, failure: { Void in
        
                let alertController = UIAlertController(title: "Erreur", message: "L'événement n'a pas été modifié.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        
        })
        
        //setMedia()
        
    }

    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showListInvited(sender: AnyObject) {
        print(listInvited.frame)
        UIView.animateWithDuration(0.3, animations: {
            self.listInvited.frame = CGRectMake(0, self.imageEvent.frame.origin.y + self.imageEvent.frame.height, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 2)
            }, completion: nil)
        self.view.bringSubviewToFront(listInvited)

    }
    
    @IBAction func showListMessages(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.listMessages.frame = CGRectMake(0, self.imageEvent.frame.origin.y + self.imageEvent.frame.height, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 2)
            }, completion: nil)
        self.view.bringSubviewToFront(listMessages)
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.eventItem?.participants?.count == nil {
            return 0
        }
        return (self.eventItem?.participants?.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("create cell")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("invitedEventCellIdentifier", forIndexPath: indexPath) as! InvitedCollectionViewCell
        
        //cell.contactImage.image = UIImage(named: "ComeOnLogo")
        //cell.contactImage.layer.cornerRadius = cell.contactImage.frame.size.width / 2
        //cell.contactImage.clipsToBounds = true
        if let avatar = self.eventItem?.participants![indexPath.row].extendedPropertyAsObject?.avatar,
            let url = NSURL(string: "http://cdn.comeon.io/\(avatar)") {
            getDataFromUrl(url) { (data, response, error)  in
                print("error: \(error)")
                print("data: \(data)")
                print("response: \(response)")
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else { return }
                    cell.contactImage.image = UIImage(data: data)
                }
            }

        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessagesEventCellIdentifier")
        return cell!
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == dateField {
            self.performSegueWithIdentifier("changeDateIdentifier", sender: nil)
            return false
        }
        return true
    }
    
    
    @IBAction func applyModification(sender: AnyObject) {
        if dateField.enabled == false && descriptionEvent.editable == false {
            modifyBtn.setTitle("Confirmer", forState: .Normal)
            dateField.enabled = true
            descriptionEvent.editable = true
            titleEvent.enabled = true
            changePictureBtn.hidden = false
            //listInvited.addContact.hidden = false
        } else {
            modifyBtn.setTitle("Modifier", forState: .Normal)
            dateField.enabled = false
            descriptionEvent.editable = false
            titleEvent.enabled = false
            changePictureBtn.hidden = true
            //listInvited.addContact.hidden = true
            performModifyEvent()
        }
    }
    
    @IBAction func changePicture(sender: AnyObject) {
 
        actionController = TweetbotActionController()
         
         actionController.addAction(Action("Prendre une photo", style: .Default, handler: { action in
            
            self.actionController.dismiss()
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                print("will take a picture")
         
                self.imagePicker.delegate = self
         
                self.imagePicker.sourceType = .Camera;
                self.imagePicker.allowsEditing = false
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
         }))
         actionController.addAction(Action("Sélectionner dans la bibliothèque", style: .Default, handler: { action in
            
            self.actionController.dismiss()
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
                print("will chose a picture")
         
                self.imagePicker.delegate = self
         
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
                self.imagePicker.allowsEditing = false
         
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
         }))
         
         actionController.addSection(Section())
         actionController.addAction(Action("Annuler", style: .Cancel, handler:nil))
         
         presentViewController(actionController, animated: true, completion: nil)
        
        
        
    }

    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageEvent.image = image
        imageEvent.contentMode = UIViewContentMode.Center;
        imageEvent.contentMode = UIViewContentMode.ScaleAspectFit
        imageEvent.clipsToBounds = true
        //imageEvent.contentMode = UIViewContentMode.ScaleToFill
        
    }
    
    
    
    func showAddContact() {
        let storyboard = UIStoryboard(name: "NewEvent", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("InviteContactsViewControllerId") as! InviteContactsViewController
        vc.reInvite = true
        vc.eventId = eventItem!.id
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    
    
}



