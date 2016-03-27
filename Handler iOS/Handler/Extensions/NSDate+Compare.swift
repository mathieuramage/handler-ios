//
//  NSDate+Compare.swift
//  Handler
//
//  Created by Ryniere S Silva on 21/03/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation

extension NSDate {

	func isLaterThanDate(date: NSDate) -> Bool {
		return timeIntervalSinceReferenceDate > date.timeIntervalSinceReferenceDate
	}

	func isEarlierThan(date: NSDate) -> Bool {
		return timeIntervalSinceReferenceDate < date.timeIntervalSinceReferenceDate
	}
}
