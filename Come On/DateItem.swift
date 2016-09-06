//
//  DateItem.swift
//  Come On
//
//  Created by Antoine roy on 05/01/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class DateItem: NSObject {

    var date: NSDate!
    var year: Int!
    var month: Int!
    var day: Int!
    var hour: Int!
    var minute: Int!
    var second: Int!
    let abrMonth: [String] = ["Jan", "Fev", "Mar", "Avr", "Mai", "Jui", "Jul", "Aou", "Sep", "Oct", "Nov", "Dec"]
    let fullMonth: [String] = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Aout", "Septembre", "Octobre", "Novembre", "Décembre"]
    
    init(src: NSDate) {
        //var myCalendar:NSCalendar = NSCalendar(calendarIdentifier: "")
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year , .Month , .Day, .Hour, .Minute, .Second], fromDate: src)
        
        date = src
        year = components.year
        month = components.month
        day = components.day
        
        hour = components.hour
        minute = components.minute
        second = components.second
        
    }
}
