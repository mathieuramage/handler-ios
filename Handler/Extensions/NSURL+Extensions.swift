//
//  NSURL+Extensions.swift
//  Handler
//
//  Created by Marco Nascimento on 12/24/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation

extension URL {
	var queryItems: [String: String]? {
		var params = [String: String]()
		return URLComponents(url: self as URL, resolvingAgainstBaseURL: false)?
			.queryItems?
			.reduce([:], { (_, item) -> [String: String] in
				params[item.name] = item.value
				return params
			})
	}
}
