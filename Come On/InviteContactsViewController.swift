//
//  InviteContactsViewController.swift
//  Come On
//
//  Created by Julien Colin on 23/03/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import ObjectMapper

class ContactsGroupCheck {
    var group: ContactsGroup!
    var collapsed: Bool = true
    var checked: Bool = false
    
    init(group: ContactsGroup) {
        self.group = group
    }
}
class InviteContactsViewController: UIViewController {
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    var comeonApi = ComeOnAPI.sharedInstance
    var eventId: Int!
    
    var localDataGroups: [ContactsGroupCheck] = []
    var localDataContacts: [ContactItem] = []
    var checkedContacts: [Int] = []
    var reInvite: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshContactsFromAPI()
        
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        contactsTableView.registerNib(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "contactsCustomCellIdentifier")
        contactsTableView.registerNib(UINib(nibName: "ContactsTableViewHeader", bundle:nil), forHeaderFooterViewReuseIdentifier: "contactsTableViewHeader")
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
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }

    @IBAction func sendInvitations(sender: AnyObject) {
        for contactId in checkedContacts {
            ComeOnAPI.sharedInstance.performRequest(EventRoute.CreateInvitationForUser(eventId: eventId, userId: contactId), failure: { (json, httpCode) -> Void in
                print("Failed to invite \(json)")
            })
        }
        dismissViewControllerAnimated(true) {
            if self.reInvite == false {
                LocalNotifications.notifEventCreated(self.checkedContacts.count)
            } else {
                LocalNotifications.notifMoreInvitationDone(self.checkedContacts.count)
            }
        }
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
            if self.reInvite == false {
                LocalNotifications.notifEventCreated(self.checkedContacts.count)
            }
        }
    }
}

extension InviteContactsViewController : UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("contactsCustomCellIdentifier", forIndexPath: indexPath) as! ContactsTableViewCell
        
        var user: ContactItem! = nil
        cell.isInGroup = indexPath.section != localDataGroups.count
        user = cell.isInGroup ? localDataGroups[indexPath.section].group!.users[indexPath.row] : localDataContacts[indexPath.row]

        cell.label?.text = user.completeName
        cell.pseudo = user.pseudo!
        cell.checkBox.on = checkedContacts.indexOf(user.id!) != nil
        cell.isSelectible = true
        
        // Round picture
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
        
        if indexPath.row + 10 > localDataContacts.count  && areContactsFullyLoad() == false { // Load next cells
            loadNextPageOfContacts()
        }

        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return localDataGroups[section].group!.name
    }
}

extension InviteContactsViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != localDataGroups.count {
            return 60.0
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != localDataGroups.count { return }
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactsTableViewCell else { return }

        if cell.checkBox.on == true { // Deselect
            checkedContacts = checkedContacts.filter{ $0 != localDataContacts[indexPath.row].id }
        } else { // Select
            checkedContacts.append(localDataContacts[indexPath.row].id)
        }
        contactsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("contactsTableViewHeader") as! ContactsTableViewHeader

        cell.tag = section
        cell.label.text = localDataGroups[section].group.name
        // Round picture
        cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2
        cell.picture.clipsToBounds = true
        cell.checkbox.on = localDataGroups[section].checked
        cell.isSelectible = true

        if localDataGroups[section].collapsed == false {
            cell.accessor.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        } else {
            cell.accessor.transform = CGAffineTransformMakeRotation(CGFloat(2*M_PI_2))
        }
        let headerTapped = UITapGestureRecognizer (target: self,
                                                   action: #selector(InviteContactsViewController.sectionHeaderTapped(_:)))
        let headerLongPressed = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(InviteContactsViewController.sectionHeaderLongPressed(_:)))
        headerLongPressed.minimumPressDuration = 0.5

        cell.gestureRecognizers = nil
        cell.addGestureRecognizer(headerLongPressed)
        cell.addGestureRecognizer(headerTapped)
        return cell
    }

    func sectionHeaderLongPressed(recognizer: UITapGestureRecognizer) {
        if let tag = recognizer.view?.tag {
            if localDataGroups[tag].checked == false {
                localDataGroups[tag].checked = true
                for user in localDataGroups[tag].group!.users {
                    checkedContacts.append(user.id!)
                }
            } else {
                localDataGroups[tag].checked = false
                for user in localDataGroups[tag].group!.users {
                    checkedContacts = checkedContacts.filter{ $0 != user.id! }
                }
            }
        }
        contactsTableView.reloadData()
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
}