//
//  Contacts.swift
//  Come On
//
//  Created by Julien Colin on 24/11/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import ObjectMapper

class Contact: Mappable {
    
    var results: [ContactItem] = []
    var currentPage: Int = 0
    var pages: Int = 0
    
    init() {}
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        results <- map["results"]
        currentPage <- map["current_page"]
        pages <- map["number_pages"]
    }
}