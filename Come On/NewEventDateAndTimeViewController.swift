//
//  NewEventDateAndTimeViewController.swift
//  Come On
//
//  Created by Julien Colin on 24/02/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class NewEventDateAndTimeViewController: UIViewController {

    var parentVC: UIViewController!
    var typeDate: Int?
    //typedate == 1 => from NewEvent
    //typedate == 2 => from manageEvent
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func dateShortcutAction(sender: AnyObject) {
//        switch sender.
        let text = (sender as! UIButton).titleLabel!.text!
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        switch text {
        case "Maintenant":
            datePicker.date = now
            break
        case "Dans 10 minutes":
            datePicker.date = calendar.dateByAddingUnit(.Minute, value: 10, toDate: now, options: [])!
            break
        case "Dans 30 minutes":
            datePicker.date = calendar.dateByAddingUnit(.Minute, value: 30, toDate: now, options: [])!
            break
        case "Dans 1 heure":
            datePicker.date = calendar.dateByAddingUnit(.Hour, value: 1, toDate: now, options: [])!
            break
        case "Demain":
            datePicker.date = calendar.dateByAddingUnit(.Day, value: 1, toDate: now, options: [])!
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if typeDate == 1 {
            datePicker.date = (parentVC as! NewEventViewController).date
        } else if typeDate == 2 {
            datePicker.date = (parentVC as! ManageEventViewController).date
        }
            // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okButtonAction(sender: AnyObject) {
        if typeDate == 1 {
            (parentVC as? NewEventViewController)!.date = datePicker.date
        } else if typeDate == 2 {
            (parentVC as? ManageEventViewController)!.date = datePicker.date
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
