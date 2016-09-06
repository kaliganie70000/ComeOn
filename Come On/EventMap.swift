//
//  EventMap.swift
//  Come On
//
//  Created by Julien Colin on 26/04/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import ObjectMapper

class EventMap: Mappable {
    
    var users: [EventMapItem]!
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        users <- map["users"]
    }
}

class EventMapItem: Mappable {
    
    var userId: Int!
    var latitude: CGFloat!
    var longitude: CGFloat!
    var message: String?
    var dateAsString: String!
    
    // Computed fields
    var date: EventMapDate!

    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        userId <- map["user_id"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        message <- map["message"]
        dateAsString <- map["date"]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dt = dateFormatter.dateFromString(dateAsString)
        date = EventMapDate(src: dt!)
    }
}

class EventMapDate: NSObject {
    
    var date: NSDate!
    var year: Int!
    var month: Int!
    var day: Int!
    var hour: Int!
    var minute: Int!
    var second: Int!
    
    init(src: NSDate) {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year , .Month , .Day, .Hour, .Minute, .Second],
                                             fromDate: src)
        
        date = src
        year = components.year
        month = components.month
        day = components.day
        hour = components.hour
        minute = components.minute
        second = components.second
    }
}
