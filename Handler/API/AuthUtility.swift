//
//  AuthUtility.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 10/07/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

struct AuthUtility {
	private static let _oAuthTokenKey = "HANDLER_OAUTH_TOKEN"
	private static var _oAuthToken : String?
	static var oAuthToken : String? {
		get {
			if let token = _oAuthToken {
				return token
			} else {
				_oAuthToken = NSUserDefaults.standardUserDefaults().stringForKey(_oAuthTokenKey)
				return _oAuthToken
			}
		}
		set {
			if let token = newValue {
				_oAuthToken = token
				NSUserDefaults.standardUserDefaults().setObject(token, forKey: _oAuthTokenKey)
			} else {
				NSUserDefaults.standardUserDefaults().removeObjectForKey(_oAuthTokenKey)
			}
		}
	}


	static func login (oauthHeaders : [String : String], callback : (success: Bool) -> () ) {

		let params = [ "client_id":Config.ClientId,
		               "grant_type":"client_credentials",
		               "client_secret": Config.ClientSecret]

		APIUtility.request(.POST, route: Config.APIRoutes.oauth, parameters: params, headers: oauthHeaders).response { (request, response, data, error) in

			if let value = response.value {
				let json = JSON(value)
				print(json)
			}
		}
		
	}
	
	
	
}
