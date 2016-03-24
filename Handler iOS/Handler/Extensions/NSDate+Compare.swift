//
//  NSDate+Compare.swift
//  Handler
//
//  Created by Ryniere S Silva on 21/03/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation

extension NSDate {
	
	func isLaterThanDate(dateToCompare: NSDate) -> Bool {
		return self.timeIntervalSinceReferenceDate > dateToCompare.timeIntervalSinceReferenceDate
	}
	
	func isEarlierThan(dateToCompare: NSDate) -> Bool {
		return self.timeIntervalSinceReferenceDate < dateToCompare.timeIntervalSinceReferenceDate
	}
}
