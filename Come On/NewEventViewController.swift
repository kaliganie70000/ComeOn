//
//  NewEventViewController.swift
//  Come On
//
//  Created by Julien Colin on 04/10/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import ObjectMapper

class NewEventViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: TitleTextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateTimeTextField: UITextField!
    
    var locationAdress: String?
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var firstLocationUpdate = true
    
    var createdEventId: Int? = nil
    
    var date = NSDate() {
        didSet {
            let diffTime = Int(date.timeIntervalSinceDate(NSDate()))
            switch diffTime {
            case 0...59:
                dateTimeTextField.text = "Maintenant"
                break
            case 60...699:
                dateTimeTextField.text = "Dans 10 minutes"
                break
            case 700...1899:
                dateTimeTextField.text = "Dans 30 minutes"
                break
            case 1900...3700:
                dateTimeTextField.text = "Dans 1 heure"
                break
            case 3701...88400:
                dateTimeTextField.text = "Demain"
                break
            default:
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "dd-MM-yyyy HH:mm"
                dateTimeTextField.text = dateFormat.stringFromDate(date)
            }
        }
    }
    
    @IBAction func createEventAction(sender: AnyObject) {
        //let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        let newEvent: [String: AnyObject] = [
            "title": titleTextField.text!,
            "date_start": formatter.stringFromDate(date),
            "latitude": currentLocation.latitude,
            "longitude": currentLocation.longitude,
            "description" : ""]
        
        ComeOnAPI.sharedInstance.performRequest(EventRoute.Create(newEvent),
            success: { (json, httpCode) -> Void in
                guard let event = Mapper<EventItem>().map(json) else {
                    return
                }
                self.createdEventId = event.id
                let alert = UIAlertController(title: "Voulez-vous inviter", message: "des amis ?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Non", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    LocalNotifications.notifEventCreated(0)
                }))
                alert.addAction(UIAlertAction(title: "Oui", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                    self.performSegueWithIdentifier("showInviteContactSegue", sender: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }, failure: { (json, httpCode) -> Void in
                var errorMessage = "Une erreur est arrivée 🤕"
                if let error = Mapper<Error>().map(json), let errorMessage_ = error.error {
                    errorMessage = errorMessage_
                }
                let alertController = UIAlertController(title: "Erreur", message: errorMessage, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)

        })
    }
    
    @IBAction func actionGetAuth(sender: AnyObject) {
        ComeOnAPI.sharedInstance.performRequest(AuthRoute.Read(), success: { (json, httpCode) -> Void in
            
            }, failure: { (json, httpCode) -> Void in
                
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        dateTimeTextField.delegate = self
        titleTextField.setUpTextField(self)
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewEventViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //    override func viewDidAppear(animated: Bool) {
    //        locationTextField.text = locationAdress
    //    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showMapSegue":
                let newEventMapVC = segue.destinationViewController as! NewEventMapViewController
                newEventMapVC.region.center = currentLocation
                newEventMapVC.parentVC = self
                break
            case "showDateTimeSegue":
                let newEventDateAndtimeVC = segue.destinationViewController as! NewEventDateAndTimeViewController
                newEventDateAndtimeVC.parentVC = self
                newEventDateAndtimeVC.typeDate = 1
                break
            case "showInviteContactSegue":
                let inviteContactsViewController = segue.destinationViewController as! InviteContactsViewController
                inviteContactsViewController.eventId = createdEventId
                createdEventId = nil
                break
            default:
                assert(false, "Segue should be prepared")
            }
        }
    }
}

extension NewEventViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool  {// return NO to disallow editing.
        if textField == dateTimeTextField {
            performSegueWithIdentifier("showDateTimeSegue", sender: nil)
        } else {
            performSegueWithIdentifier("showMapSegue", sender: nil)
        }
        return false
    }
}

extension NewEventViewController: CLLocationManagerDelegate {
    
    // Called each time the GPD update the user location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if firstLocationUpdate {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            currentLocation.latitude = locValue.latitude
            currentLocation.longitude = locValue.longitude
            firstLocationUpdate = false
        }
    }
}

class TitleTextField: UITextField {

    var parentVC: UIViewController!
    
    func setUpTextField(parentVC: UIViewController?) {
        delegate = self
        self.parentVC = parentVC
    }
}

extension TitleTextField: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
