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

	static var defaultHeaders : HTTPHeaders = ["Cache-Control" : "no-cache", "Content-Type" : "application/json"]

	static func request(method : HTTPMethod, route : String, parameters : [String : Any]?) -> DataRequest {
        return request(method: method, route: route, parameters: parameters, headers: nil)
	}

	static func request(method : HTTPMethod, route : String, parameters : [String : Any]?, headers : [String : String]?) -> DataRequest {

		let urlString = Config.APIURL + route
		var allHeaders = defaultHeaders

		if let headers = headers {
			for (key, val) in headers {
				allHeaders[key] = val
			}
		}

		if let accessToken = AuthUtility.shared.accessToken {
			allHeaders["Authorization"] = "bearer \(accessToken.token)"
		}

		var parameterEncoding : ParameterEncoding
		if (method == .get || method == .delete) {
			parameterEncoding = URLEncoding(destination: .queryString)
		} else {
			parameterEncoding = JSONEncoding.default
		}
        return Alamofire.request(urlString, method: method , parameters: parameters, encoding: parameterEncoding, headers: allHeaders)
	}
}

struct APIError {
	var status : Int
	var title : String
	var detail : String
}


