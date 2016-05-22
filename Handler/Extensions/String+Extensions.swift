//
//  String+Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation

extension String {
	var firstCapitalized: String {
		var string = self.lowercaseString
		string.replaceRange(string.startIndex...string.startIndex, with: String(string[string.startIndex]).capitalizedString)
		return string
	}
}

extension NSData {
	
	public var hexadecimalString: NSString {
		var bytes = [UInt8](count: length, repeatedValue: 0)
		getBytes(&bytes, length: length)
		
		let hexString = NSMutableString()
		for byte in bytes {
			hexString.appendFormat("%02x", UInt(byte))
		}
		
		return NSString(string: hexString)
	}
}