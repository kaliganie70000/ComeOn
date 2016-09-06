//
//  Image.swift
//  Come On
//
//  Created by Antoine roy on 10/07/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import ObjectMapper
import MapKit

class Image: Mappable {

    var id: Int?
    var name: String?
    var path: String?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        path <- map["path"]
    }
    
    func toString() {
        print("Image class:")
        print("id: \(id), name: \(name), path: \(path)")
    }
    
}
