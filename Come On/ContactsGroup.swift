//
//  Group.swift
//  Come On
//
//  Created by Julien Colin on 13/01/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import ObjectMapper

class ContactsGroups: Mappable {
    
    var results: [ContactsGroup]!
    
    init() {}
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        results <- map["results"]
    }
}

class ContactsGroup: Mappable {
    var id: Int?
    var name: String?
    var users: [ContactItem]!
    
    init() {}
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        users <- map["users"]
    }
}

// Different return when PUT request to rename a group

class ContactsGroupUpdate: Mappable {
    var id: Int!
    var group: ContactsGroup!
    
    init() {}
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        group <- map["group"]
    }
}
