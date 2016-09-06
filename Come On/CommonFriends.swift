//
//  CommonFriends.swift
//  Come On
//
//  Created by Julien Colin on 20/04/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import ObjectMapper

class CommonFriends: Mappable {
    
    var results: [ContactItem]!
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        results <- map["results"]
    }
}
