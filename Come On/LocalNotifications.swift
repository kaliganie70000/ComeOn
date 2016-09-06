//
//  LocalNotifications.swift
//  Come On
//
//  Created by Julien Colin on 19/04/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import Foundation
import BRYXBanner

class LocalNotifications {
    
    static func notifEventCreated(nbInvitations: Int) {
        let subtitle: String!
        switch nbInvitations {
        case 0:
            subtitle = "Mais personne n'est invité 🙁"
            break
        case 1:
            subtitle = "Et 1 personne a été invitée 😀"
            break
        default:
            subtitle = "Et \(nbInvitations) personnes ont été invitées ! 😁"
            break
        }
        createNotif("Évènement créé",
                    backgroundColor: UIColor(red: 48.00/255.0, green: 174.0/255.0, blue: 51.5/255.0, alpha:1.000),
                    subtitle: subtitle, duration: 3.0)
    }
    
    static func notifMoreInvitationDone(nbInvitations: Int) {
        
        let subtitle: String!
        switch nbInvitations {
        case 1:
            subtitle = "1 personne a été invitée."
            break
        default:
            subtitle = "\(nbInvitations) personnes ont été invitées ! 😁"
            break
        }
        
        createNotif(subtitle,
                    backgroundColor: UIColor(red: 48.00/255.0, green: 174.0/255.0, blue: 51.5/255.0, alpha:1.000),
                    subtitle: subtitle, duration: 3.0)
    }
    
    static func notifFriendRequest() {
        createNotif("Requête d'ami envoyée !", backgroundColor: CustomColors.notifBlue())
    }
    
    static func notifFriendRequestAccepted() {
        createNotif("Requête d'ami acceptée 😀", backgroundColor: CustomColors.notifBlue())
    }
    
    static func notifFriendRequestDenied() {
        createNotif("Requête d'ami refusée 😥", backgroundColor: CustomColors.notifBlue())
    }
    
    static func notifFriendRequestCancelled() {
        createNotif("Requête d'ami annulée 😥", backgroundColor: CustomColors.notifBlue())
    }
    
    static func notifFriendDeleted() {
        createNotif("Vous avez perdu un ami. 😞", backgroundColor: CustomColors.notifBlue())
    }
    
    static func notifSomethingBadHappend(error: String) {
        createNotif(error, backgroundColor: CustomColors.notifRed())
    }
    
    /// The Banner library should be used only in this function
    static private func createNotif(title: String, backgroundColor: UIColor, subtitle: String = "", duration: NSTimeInterval = 1.0) {
        let banner = Banner(title: title,
                            subtitle: subtitle,
                            image: nil,
                            backgroundColor: backgroundColor)
        banner.dismissesOnTap = false
        banner.show(duration: duration)
    }
}
