//
//  Error.swift
//  Come On
//
//  Created by Julien Colin on 07/10/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import ObjectMapper

class Error: Mappable {
    
    var error: String?
    var errorCode: Int?
    var errorDetails: AnyObject?
    
    init() {}
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        errorCode <- map["error_code"]
        errorDetails <- map["error_details"]
    }
}