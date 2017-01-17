//
//  NSDate+FromString.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation

extension Date {
	
	static func fromUTCString(_ string: String) -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		return formatter.date(from: string)
	}
	
	static func toUTCString(_ date: Date?) -> String? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		if let date = date {
			return formatter.string(from: date)
		} else {
			return nil
		}
	}
	
	var NSDateValue : NSDate {
		return NSDate(timeIntervalSince1970: self.timeIntervalSince1970)
	}
	
	func isLaterThanDate(_ date: Date) -> Bool {
		return timeIntervalSinceReferenceDate > date.timeIntervalSinceReferenceDate
	}
	
	func isEarlierThan(_ date: Date) -> Bool {
		return timeIntervalSinceReferenceDate < date.timeIntervalSinceReferenceDate
	}
	
}

extension NSDate {
	
	func isLaterThanDate(_ date: Date) -> Bool {
		return timeIntervalSinceReferenceDate > date.timeIntervalSinceReferenceDate
	}
	
	func isEarlierThan(_ date: Date) -> Bool {
		return timeIntervalSinceReferenceDate < date.timeIntervalSinceReferenceDate
	}
}
