//
//  String+Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation

extension String {
	var firstCapitalized: String {
		var string = self.lowercaseString
		string.replaceRange(string.startIndex...string.startIndex, with: String(string[string.startIndex]).capitalizedString)
		return string
	}

}