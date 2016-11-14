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
		var string = self.lowercased()
		string.replaceSubrange(string.startIndex...string.startIndex, with: String(string[string.startIndex]).capitalized)
		return string
	}
}

extension Data {
	
	public var hexadecimalString: NSString {
		var bytes = [UInt8](repeating: 0, count: count)
		copyBytes(to: &bytes, count: count)
		
		let hexString = NSMutableString()
		for byte in bytes {
			hexString.appendFormat("%02x", UInt(byte))
		}
		
		return NSString(string: hexString)
	}
}
