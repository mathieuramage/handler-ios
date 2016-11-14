//
//  NSDate+Compare.swift
//  Handler
//
//  Created by Ryniere S Silva on 21/03/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation

extension Date {

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
