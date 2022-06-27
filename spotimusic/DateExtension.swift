//
//  DateExtension.swift
//  GroupInitArchitecture
//
//  Created by Ravi Deshmukh on 19/03/18.
//  Copyright © 2018 Barquecon Technology pvt ltd. All rights reserved.
//

import Foundation

extension Date {
    func stringFromDate(with format: String) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "IST")
        let myString = formatter.string(from: self)
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = format
        // again convert your date to string
        return formatter.string(from: yourDate!)
    }


    
    func localDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: self)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: myString)
    }
    
    func addTimeComponent(hour: Int, minute: Int) -> Date? {
        var date = self.dateWithoutTime()
        date = Calendar.current.date(byAdding: .hour, value: hour, to: date)!
        return Calendar.current.date(byAdding: .minute, value: minute, to: date)
    }
    
    func utcDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let dateString = dateFormatter.string(from: self)
        let istdate = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let datestr = dateFormatter.string(from: istdate!)
        return datestr
    }
    
    func removeTimeStamp() -> Date {
        guard let date = Calendar.current.date(from:Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
    
    func dateWithoutTime() -> Date {
        var calender = Calendar.current
        calender.locale = Locale.current
        let components = calender.dateComponents([.year, .month, .day], from: self)
        let newDate = calender.date(from: components)
        return newDate!
    }
}

extension String {
    func stringFromUTCDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale.current
        if let date = date {
            return dateFormatter.string(from: date)
        }else {
            return ""

        }
    }

    func shortDateFromDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        //        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date!)
    }
}
