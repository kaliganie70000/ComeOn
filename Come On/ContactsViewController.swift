//
//  ContactsViewController.swift
//  Come On
//
//  Created by Julien Colin on 28/09/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import UIKit
import ObjectMapper

class ContactsViewController: UIViewController, GridComponent {
    
    var viewCopy: UIView?
    var originView: UIView?
    var originIndexPath: NSIndexPath?
    var locationBaganTouchInTableView: CGPoint?
    
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var searchTableView: SearchTableView!
    @IBOutlet weak var contactsTableView: UITableView!
    
    var rootVC: HomeViewController!
    
    var comeonApi = ComeOnAPI.sharedInstance
    
    var localDataGroups:   [ContactsGroupCheck] = []
    var localDataContacts: [ContactItem] =        []
    
    /// Fires when Back button pressed
    ///
    /// Scroll to the view on left
    @IBAction func backPressed(sender: AnyObject) {
        rootVC.scrollToPage(1)
    }
    
    /// Fires when creation of a new group of friends
    @IBAction func newGroup(sender: AnyObject) {
        let alertController = UIAlertController(title: "New group of friends", message: nil, preferredStyle: .Alert)
        let createAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.Default) { UIAlertAction in
            ComeOnAPI.sharedInstance.performRequest(UserRoute.CreateGroup(meId: ComeOnAPI.sharedInstance.auth!.id!,
                name: alertController.textFields!.first!.text!), success: {
                    (json, httpCode) -> Void in
                    if let newGroup = Mapper<ContactsGroupUpdate>().map(json) {
                        self.refreshContactsFromAPI()
                    }
            })
        }
        createAction.enabled = true
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { UIAlertAction in }
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Name of your group"
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                createAction.enabled = textField.text?.characters.count >= 1
            }
        }
        alertController.view.setNeedsLayout()
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Fires when Search button pressed
    ///
    /// 1/2 Hide contacts UITableView & show search UITableView + search Bar
    ///
    /// 1/2 Show contacts UITableView & hide search UITableView + search Bar
    @IBAction func searchAction(sender: AnyObject) {
        let shouldHideSearchBar = searchBarTopConstraint.constant != 0
        
        if shouldHideSearchBar {                                            // Show contacts
            searchBarTopConstraint.constant = 0
            self.searchView.resignFirstResponder()
            searchView.delegate?.searchBar!(searchView, textDidChange: "")
        } else {                                                            // Show Search
            searchBarTopConstraint.constant = 44
            self.searchView.becomeFirstResponder()
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (_) -> Void in
            self.searchView.text = ""
            self.searchTableView.hidden = shouldHideSearchBar
            self.contactsTableView.hidden = !shouldHideSearchBar
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        searchTableView.setUpTableView(self)
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        contactsTableView.registerNib(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "contactsCustomCellIdentifier")
        contactsTableView.registerNib(UINib(nibName: "ContactsTableViewHeader", bundle:nil), forHeaderFooterViewReuseIdentifier: "contactsTableViewHeader")
        
        searchView.delegate = self
        
        refreshContactsFromAPI()
    }
    
    
    
    func refreshContactsFromAPI() {
        self.localDataGroups = []
        self.localDataContacts = []
        self.comeonApi.datas.contacts = Contact()
        self.comeonApi.datas.groups = []
        loadNextPageOfContacts()
    }
    
    func areContactsFullyLoad() -> Bool {
        return comeonApi.datas.contacts.currentPage > comeonApi.datas.contacts.pages
    }
    
    func loadNextPageOfContacts() {
        let pageToLoad = self.comeonApi.datas.contacts.currentPage + 1
        self.comeonApi.datas.contacts.currentPage = pageToLoad
        
        ComeOnAPI.sharedInstance.performRequest(UserRoute.ReadContacts(userId: ComeOnAPI.sharedInstance.auth!.id!, page: pageToLoad), success: {
            (json, httpCode) -> Void in
            if let contacts = Mapper<Contact>().map(json) {
                self.comeonApi.datas.contacts.pages = contacts.pages
                self.comeonApi.datas.contacts.results.appendContentsOf(contacts.results)
                
                self.localDataContacts = self.comeonApi.datas.contacts.results
            }
            }, after: { () -> Void in
                if pageToLoad == 1 {
                ComeOnAPI.sharedInstance.performRequest(UserRoute.ReadGroups(userId: ComeOnAPI.sharedInstance.auth!.id!), success: {
                    (json, httpCode) -> Void in
                    if let contactsGroups = Mapper<ContactsGroups>().map(json) {
                        self.comeonApi.datas.groups.appendContentsOf(contactsGroups.results)
                        self.localDataGroups = self.comeonApi.datas.groups.map { ContactsGroupCheck(group: $0) }
                    }
                    }, after: { () -> Void in
                        
                        self.contactsTableView.reloadData()
                })
                } else {
                        self.contactsTableView.reloadData()
                }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let contactVC = segue.destinationViewController as! ContactViewController
        if sender as? UITableView == self.searchTableView {
            if let indexPath = searchTableView.indexPathForSelectedRow {
                contactVC.contactId = searchTableView.searchResults![indexPath.row].id
            }
        } else {
            if let indexPath = contactsTableView.indexPathForSelectedRow {
                if indexPath.section != localDataGroups.count {
                    contactVC.contactId = localDataGroups[indexPath.section].group!.users[indexPath.row].id
                } else {
                    contactVC.contactId = localDataContacts[indexPath.row].id
                }
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func didScrollToViewController(scrollView: UIScrollView) {
        refreshContactsFromAPI()
    }
    
    func findGroupWithId(id: Int) -> ContactsGroupCheck? {
        if let found = localDataGroups.indexOf({$0.group.id! == id}) {
            return localDataGroups[found]
        }
        return nil
    }
}


extension ContactsViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == localDataGroups.count { // Last section -> all users without groups
            return localDataContacts.count
        }
        return localDataGroups[section].collapsed == false ? localDataGroups[section].group.users.count : 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return localDataGroups.count + 1
    }
    
    /// Load next cells if end of scrollView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactsCustomCellIdentifier",
                                                               forIndexPath: indexPath) as! ContactsTableViewCell
        
        cell.tag = -1 * indexPath.row
        
        var user: ContactItem! = nil
        cell.isInGroup = indexPath.section != localDataGroups.count
        user = cell.isInGroup ? localDataGroups[indexPath.section].group!.users[indexPath.row] : localDataContacts[indexPath.row]
        
        cell.label?.text = user.completeName
        cell.pseudo = user.pseudo!
        //        cell.checkBox.on = ?
        
        // Round picture
        cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2
        cell.picture.clipsToBounds = true
        cell.picture!.image = UIImage(named: "comeon_profile")
        if let avatar = user.extendedPropertyAsObject?.avatar, let url = NSURL(string: "http://cdn.comeon.io/\(avatar)") {
            getDataFromUrl(url) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else { return }
                    cell.picture!.image = UIImage(data: data)
                }
            }
        }
        
        if cell.isInGroup == false {
            let cellLongPressed = UILongPressGestureRecognizer(target: self,
                                                           action: #selector(ContactsViewController.cellLongPressed(_:)))
            cellLongPressed.minimumPressDuration = 0.5
            cell.addGestureRecognizer(cellLongPressed)
        }
        
        if indexPath.row + 10 > localDataContacts.count  && areContactsFullyLoad() == false { // Load next cells
            loadNextPageOfContacts()
        }
        return cell
    }
    
    func cellLongPressed(recognizer: UITapGestureRecognizer) {
        
        var locationInTableView = recognizer.locationInView(contactsTableView)
        if (recognizer.state == UIGestureRecognizerState.Began)
        {
            originView = recognizer.view
            originIndexPath = contactsTableView.indexPathForRowAtPoint(locationInTableView)
            viewCopy = UIImageView(image: UIImage.imageWithView(originView!))
            viewCopy?.tag = -1000
            viewCopy!.frame = originView!.frame
            contactsTableView.addSubview(viewCopy!)
            locationBaganTouchInTableView = recognizer.locationInView(contactsTableView)
        }
        else if (recognizer.state == UIGestureRecognizerState.Changed)
        {
            if originIndexPath!.section != localDataGroups.count { // If contact moved comes from a group
                if viewCopy?.subviews.count == 0 {
                    let imageView = UIImageView(frame: CGRectMake(0, 10, 40, 40))
                    imageView.image = UIImage(named: "ic_clear")
                    imageView.tintColor = UIColor.redColor()
                    imageView.alpha = 0
                    viewCopy?.addSubview(imageView)
                    UIView.animateWithDuration(0.75, animations: { 
                        imageView.alpha = 1
                    })
                }
            }
            locationInTableView.x = originView!.frame.origin.x + (locationInTableView.x - locationBaganTouchInTableView!.x)
            locationInTableView.y = originView!.frame.origin.y + (locationInTableView.y - locationBaganTouchInTableView!.y)
            print(locationInTableView)
            viewCopy!.frame.origin = locationInTableView
        }
        else if (recognizer.state == UIGestureRecognizerState.Ended)
        {
            var destinationGroup: ContactsGroupCheck?
            for subView in contactsTableView.subviews {
                if subView.frame.height == contactsTableView.frame.height || subView.tag == -1000 || locationInTableView.x < subView.frame.origin.x
                    || locationInTableView.x > subView.frame.origin.x + subView.frame.width
                    || locationInTableView.y < subView.frame.origin.y
                    || locationInTableView.y > subView.frame.origin.y + subView.frame.height
                {
                    continue
                } else {
                    if subView.tag >= 0 {
                        destinationGroup = localDataGroups[subView.tag]
                    }
                }
            }

            if let destinationGroup = destinationGroup {
                ComeOnAPI.sharedInstance.performRequest(UserRoute.CreateUserInGroup(meId: ComeOnAPI.sharedInstance.auth!.id!, groupId: destinationGroup.group.id!, userId: localDataContacts[originIndexPath!.row].id), success: nil, after: {
                        if self.originIndexPath!.section == self.localDataGroups.count { // Don't refresh if the 2nd will do
                            self.refreshContactsFromAPI()
                        }
                })
            }
            UIView.animateWithDuration(0.75, animations: {
                    self.viewCopy?.alpha = 0
                }, completion: { (Bool) in
                    self.viewCopy?.removeFromSuperview()
            })
            if originIndexPath!.section != localDataGroups.count { // If contact moved comes from a group
                ComeOnAPI.sharedInstance.performRequest(UserRoute.DeleteUserInGroup(meId: ComeOnAPI.sharedInstance.auth!.id!, groupId: localDataGroups[originIndexPath!.section].group.id!, userId: localDataContacts[originIndexPath!.row].id), success: nil, after: { self.refreshContactsFromAPI() })
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return localDataGroups[section].group!.name
    }
    
    //Checks if needed
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
}

extension ContactsViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != localDataGroups.count {
            return 66.0
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    //Check if needed
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
            print("more button tapped")
        }
        more.backgroundColor = UIColor.lightGrayColor()
        
        let favorite = UITableViewRowAction(style: .Normal, title: "Favorite") { action, index in
            print("favorite button tapped")
        }
        favorite.backgroundColor = UIColor.orangeColor()
        
        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            print("share button tapped")
        }
        share.backgroundColor = UIColor.blueColor()
        
        return [share, favorite, more]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showContact", sender: tableView)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("contactsTableViewHeader") as! ContactsTableViewHeader
        
        cell.tag = section
        cell.label.text = localDataGroups[section].group.name
        
        // Round picture
        cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2
        cell.picture.clipsToBounds = true
        //        cell.checkbox.on = ?
        
        if localDataGroups[section].collapsed == false {
            cell.accessor.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        } else {
            cell.accessor.transform = CGAffineTransformMakeRotation(CGFloat(2*M_PI_2))
        }
        
        let headerTapped = UITapGestureRecognizer (target: self,
                                                   action: #selector(ContactsViewController.sectionHeaderTapped(_:)))
        let headerLongPressed = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(ContactsViewController.sectionHeaderLongPressed(_:)))
        headerLongPressed.minimumPressDuration = 0.5
        
        cell.gestureRecognizers = nil
        cell.addGestureRecognizer(headerLongPressed)
        cell.addGestureRecognizer(headerTapped)
        return cell
    }
    
    // Group Open / Close
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        if let tag = recognizer.view?.tag {
            if localDataGroups[tag].collapsed == false {
                localDataGroups[tag].collapsed = true
            } else {
                localDataGroups[tag].collapsed = false
            }
            contactsTableView.reloadData()
        }
    }
    
    // Group Rename
    func sectionHeaderLongPressed(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Began) {
            if let tag = recognizer.view?.tag, let editedGroup = self.localDataGroups[tag].group {
                
                let alertController = UIAlertController(title: "Change the name easily !", message: nil, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { UIAlertAction in
                    ComeOnAPI.sharedInstance.performRequest(UserRoute.UpdateGroup(userId: ComeOnAPI.sharedInstance.auth!.id!,
                        groupId: editedGroup.id!, newName: alertController.textFields!.first!.text!), success: {
                            (json, httpCode) -> Void in
                            if let newGroup = Mapper<ContactsGroupUpdate>().map(json) {
                                editedGroup.name = newGroup.group.name
                                self.contactsTableView.reloadData()
                            }
                    })
                }
                okAction.enabled = true
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { UIAlertAction in }
                
                let destroyAction = UIAlertAction(title: "Destroy group", style: UIAlertActionStyle.Destructive) { (action) in
                    ComeOnAPI.sharedInstance.performRequest(UserRoute.DeleteGroup(userId: ComeOnAPI.sharedInstance.auth!.id!,
                        groupId: editedGroup.id!), success: {
                            (json, httpCode) -> Void in
                            self.refreshContactsFromAPI()
                    })
                }
                alertController.addAction(destroyAction)
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                
                alertController.addTextFieldWithConfigurationHandler { textField in
                    textField.text = editedGroup.name
                    NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                        okAction.enabled = textField.text?.characters.count >= 1
                    }
                }
                alertController.view.setNeedsLayout()
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension UIImage {
    class func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension ContactsViewController : UISearchBarDelegate {
    
    // called when text changes (including clear)
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count >= 3 {
            ComeOnAPI.sharedInstance.performRequest(UserRoute.ReadSearch(search: searchText),
                                                    success: { (json, httpCode) -> Void in
                                                        if let contact = Mapper<Contact>().map(json) {
                                                            self.searchTableView.searchResults = contact.results
                                                            self.searchTableView.reloadData()
                                                        }
                },
                                                    failure: { (json, httpCode) -> Void in
            })
        } else {
            if self.searchTableView.searchResults?.isEmpty == false {
                self.searchTableView.searchResults = []
                self.searchTableView.reloadData()
            }
        }
    }
}

// MARK: - SearchTableView

class SearchTableView: UITableView {
    
    var searchResults: [ContactItem]?
    var parentVC: UIViewController?
    
    func setUpTableView(parentVC: UIViewController?) {
        delegate = self
        dataSource = self
        registerNib(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "contactsSearchCustomCellIdentifier")
        self.parentVC = parentVC
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
}

extension SearchTableView: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let searchResults = searchResults else {
            return 0
        }
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactsSearchCustomCellIdentifier", forIndexPath: indexPath) as! ContactsTableViewCell
        
        let user: ContactItem! = searchResults![indexPath.row]
        
        cell.isInGroup = false
        cell.label?.text = user.completeName
        cell.pseudo = user.pseudo!
        //        cell.checkBox.on = ?
        cell.label.text = user.pseudo!
        
        cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2
        cell.picture.clipsToBounds = true
        if let avatar = user.extendedPropertyAsObject?.avatar, let url = NSURL(string: "http://cdn.comeon.io/\(avatar)") {
            getDataFromUrl(url) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else { return }
                    cell.picture!.image = UIImage(data: data)
                }
            }
        }
        return cell
    }
    
    
}

extension SearchTableView: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parentVC?.performSegueWithIdentifier("showContact", sender: tableView)
    }
}

