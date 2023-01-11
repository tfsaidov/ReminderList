//
//  Date+Today.swift
//  ReminderList
//
//  Created by Саидов Тимур on 10.01.2023.
//

import Foundation

extension Date {
    
    var dayAndTimeText: String {
        let timeText = formatted(date: .omitted, time: .shortened)
        
        if Locale.current.calendar.isDateInToday(self) {
            let timeFormat = NSLocalizedString("Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText)
        }
        
        let dateText = formatted(.dateTime.month(.abbreviated).day())
        let dateAndTimeFormat = NSLocalizedString("%@ at %@", comment: "Date and time format string")
        return String(format: dateAndTimeFormat, dateText, timeText)
    }
    
    var dayText: String {
        if Locale.current.calendar.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Today due date description")
        }
        
        return formatted(.dateTime.month().day().weekday(.wide))
    }
}
