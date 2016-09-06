//
//  EventTableViewCell.swift
//  Come On
//
//  Created by Antoine roy on 06/01/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelParticipant: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var btnValidEvent: UIButton!
    
    var stateBtn: Int = 0
    var event: EventItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnValidEvent.tag = 0
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func acceptInvitation() {
        ComeOnAPI.sharedInstance.performRequest(EventRoute.AcceptInvitation(id: event.id!),
            success: { (json, httpCode) -> Void in
                print("event : \(self.event.toString()) accepted")
            },
            failure: { (json, httpCode) -> Void in
                print("failure for event \(self.event.toString())")
        })
    }
    
    func rejectInvitation() {
        ComeOnAPI.sharedInstance.performRequest(EventRoute.RejectInvitation(id: event.id!),
            success: { (json, httpCode) -> Void in
                print("event : \(self.event.toString()) rejected")
            },
            failure: { (json, httpCode) -> Void in
                print("failure for event \(self.event.toString())")
        })
    }
    
    @IBAction func changeAnswerEvent(sender: AnyObject) {
        print("hello man ... answer? \(event.answer!)")
        if (stateBtn == 0) {
            btnValidEvent.setBackgroundImage(UIImage(named: "checkBoxValide"), forState: .Normal)
            acceptInvitation()
            stateBtn = 1
        } else if (stateBtn == 1) {
            btnValidEvent.setBackgroundImage(UIImage(named: "checkBoxInvalide"), forState: .Normal)
            rejectInvitation()
            stateBtn = 2
        } else if (stateBtn == 2) {
            btnValidEvent.setBackgroundImage(UIImage(named: "checkBoxValide"), forState: .Normal)
            acceptInvitation()
            stateBtn = 1
        }
    }
    
    func setCheckBox(state: String) {
        if state == "accepted" {
            btnValidEvent.setBackgroundImage(UIImage(named: "checkBoxValide"), forState: .Normal)
            stateBtn = 1
        } else if state == "refused" {
            btnValidEvent.setBackgroundImage(UIImage(named: "checkBoxInvalide"), forState: .Normal)
            stateBtn = 2
        }
    }
    
    func initAccordingEvent(aEvent: EventItem) {
        self.event = aEvent
        print("print according \(unsafeAddressOf(aEvent)) and \(unsafeAddressOf(self.event))")
    }
}
