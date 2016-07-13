//
//  APIUtility.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/06/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import Alamofire

struct APIUtility {

	static var defaultHeaders : [String: String] = [:]

	static func request(method : Alamofire.Method, route : String, parameters : [String : AnyObject]?) -> Request {
		return request(method, route: route, parameters: parameters, headers: nil)
	}

	static func request(method : Alamofire.Method, route : String, parameters : [String : AnyObject]?, headers : [String : String]?) -> Request {

		let URLString = Config.APIURL + route

		var allHeaders = defaultHeaders

		if let headers = headers {
			for (key, val) in headers {
				allHeaders[key] = val
			}
		}

		if let token = AuthUtility.oAuthToken {
			allHeaders["Authorization"] = "Bearer \(token)"
		}

		var parameterEncoding : ParameterEncoding
		if (method == .GET || method == .DELETE) {
			parameterEncoding = .URL
		} else {
			parameterEncoding = .JSON
		}
		return Alamofire.request(method, URLString, parameters: parameters, encoding: parameterEncoding, headers: allHeaders)
	}
	
}
