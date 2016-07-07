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

	var defaultHeaders : [String: Anyobject] = [:]

	static func request(method : Alamofire.Method, route : String, parameters : [String : AnyObject]?) -> Request {

		let URLString = APIConfig.rootURL + route

		var params : [String  : AnyObject]

		if parameters == nil {
			params = [String : AnyObject]()
		} else {
			params = parameters!
		}

		var parameterEncoding : ParameterEncoding

		if (method == .GET || method == .DELETE) {
			parameterEncoding = .URL
		} else {
			parameterEncoding = .JSON
		}

		return Alamofire.request(method, URLString, parameters: params, encoding: parameterEncoding, headers: defaultHeaders)
	}

}
