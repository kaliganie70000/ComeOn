//
//  Event.swift
//  Come On
//
//  Created by Antoine roy on 02/01/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import ObjectMapper

class Event: Mappable {
    
    var results: [EventItem]?
    var nbPages: Int?
    var currentPage: Int?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        results <- map["results"]
        nbPages <- map["number_pages"]
        currentPage <- map["current_page"]
    }
}



class EventParticipants: Mappable {
    
    var results: [ContactItem]?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        results <- map["results"]
    }
}

class EventImage: Mappable {
    
    var results: [Image]?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        results <- map["results"]
    }
}

class EventSingle: Mappable {
    
    var str_date: String?
    var description: String?
    var title: String?
    var state: String?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        str_date <- map["date_start"]
        description <- map["description"]
        title <- map["title"]
        state <- map["event_state"]

    }
    
}
