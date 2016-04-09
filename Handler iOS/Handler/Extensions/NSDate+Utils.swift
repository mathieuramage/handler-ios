//
//  NSDate+Utils.swift
//  Handler
//
//  Created by Ryniere S Silva on 09/04/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation

extension NSDate {
	
	func addNoOfDays(noOfDays:Int) -> NSDate! {
		let cal:NSCalendar = NSCalendar.currentCalendar()
		cal.timeZone = NSTimeZone(abbreviation: "UTC")!
		let comps:NSDateComponents = NSDateComponents()
		comps.day = noOfDays
		
		return cal.dateByAddingComponents(comps, toDate: self, options: NSCalendarOptions.MatchFirst)
	}
	
	func removeNoOfDays(noOfDays:Int) -> NSDate! {
		return addNoOfDays(-noOfDays)
	}
}
