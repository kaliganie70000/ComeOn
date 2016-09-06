//
//  Auth.swift
//  Come On
//
//  Created by Julien Colin on 06/10/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import ObjectMapper

class Auth: Mappable {
  
  var apiKey: String?
  var email: String?
  var id: Int?
  var pseudo: String?
  var rights: AnyObject?
  
  required init?(_ map: Map) {
    mapping(map)
  }
  
  func mapping(map: Map) {
    apiKey <- map["api_key"]
    email <- map["email"]
    id <- map["id"]
    pseudo <- map["pseudo"]
    rights <- map["rights"]
  }
}