//
//  NSDate+FromString.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation

extension NSDate {
	class func fromString(string: String) -> NSDate? {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		
		return formatter.dateFromString(string)
	}
	
	class func toString(date: NSDate?) -> String? {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		if let date = date {
			return formatter.stringFromDate(date)
		}else{
			return nil
		}
	}
}