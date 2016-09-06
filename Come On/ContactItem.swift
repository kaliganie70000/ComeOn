//
//  Contact.swift
//  Come On
//
//  Created by Julien Colin on 24/11/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import ObjectMapper

class ContactItem: Mappable { // Rename to Contact
    
    var id: Int!
    var isProfessional: AnyObject?
    var isAdmin: AnyObject?
    var isActive: AnyObject?
    
    var pseudo: String?
    var title: String?
    var firstName: String?
    var lastName: String?
    var birthday: String?
    var extendedProperty: String?
    var description: String?
    
    var friend: Bool?
    
    // Computed properties
    var extendedPropertyAsObject: ExtendedProperty?
    var completeName: String! // firstname + lastname
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isProfessional <- map["is_professional"]
        isAdmin <- map["is_admin"]
        isActive <- map["is_active"]
        
        pseudo <- map["pseudo"]
        title <- map["title"]
        firstName <- map["firstname"]
        lastName <- map["lastname"]
        birthday <- map["birthday"]
        extendedProperty <- map["extended_property"]
        description <- map["description"]
        
        friend <- map["friend"]
        
        guard let extendedProperty = extendedProperty else {
            return
        }
        extendedPropertyAsObject = Mapper<ExtendedProperty>().map(extendedProperty)
        
        completeName = displayableNamefrom(firstname: firstName, lastname: lastName)
    }
    
    func displayableNamefrom(firstname f: String?, lastname l: String?) -> String {
        if let f = f {
            if let l = l {
                return "\(f) \(l)"
            } else {
                return f
            }
        } else {
            if let l = l {
                return l
            } else {
                return ""
            }
        }
    }
}

class ExtendedProperty: Mappable {
    
    var avatar: String?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        avatar <- map["avatar"]
    }
}
