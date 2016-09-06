//
//  EventItem.swift
//  Come On
//
//  Created by Antoine roy on 02/01/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import ObjectMapper
import MapKit

class EventItem: Mappable {

    var id: Int?
    var title: String?
    var date_start: DateItem?
    var state: String?
    var string_date_start: String?
    var date_end: DateItem?
    var description: String?
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var resume: String?
    var participants: [ContactItem]?
    var messages: Int?
    var answer: Int?
    var ownerId: Int?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        
        string_date_start <- map["date_start"]
        description <- map["description"]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dt = dateFormatter.dateFromString(string_date_start!)
        date_start = DateItem(src: dt!)
        

        participants = []
        state <- map["event_state"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        
        ownerId <- map["owner.id"]
        messages = 0
        answer = 0
    }
    
    func toString() {
        print("Event: ")
        print("title: \(title)")
        print("date: \(string_date_start)")
        print("id: \(id)")
        print("owner: \(ownerId))")
    }
    
    /*init(title: String, date: String, place: String, parts: Int) {
        super.init()
        self.title = title
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        print("---------------")
        print(date)
        let dt = dateFormatter.dateFromString(date)
        print(dt)
        //self.date = DateItem(src: dt!)
        
        self.participants = parts
        messages = 0
    }*/
    
    func getParticipantOfId(userId: Int) -> ContactItem? {
        guard let participants = participants else { return nil }
        for p in participants {
            if p.id == userId { return p }
        }
        return nil
    }
}
