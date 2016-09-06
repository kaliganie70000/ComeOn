//
//  Groups.swift
//  Come On
//
//  Created by Julien Colin on 24/11/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import ObjectMapper

class Groups: Mappable { // Rename to Groups
    
    var results: []?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        results <- map["results"]
    }
}