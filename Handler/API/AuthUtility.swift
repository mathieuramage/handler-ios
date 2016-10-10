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
	private static let _accessTokenKey = "HR_ACCESS_TOKEN_KEY"
	private static var _accessToken : AccessToken?
	static var accessToken : AccessToken? {
		get {
			if let token = _accessToken {
				return token
			} else {
				if let data = NSUserDefaults.standardUserDefaults().objectForKey(_accessTokenKey) as? NSData {
					_accessToken = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? AccessToken
				}
				return _accessToken
			}
		}
		set {
			if let token = newValue {
				_accessToken = token
				let data = NSKeyedArchiver.archivedDataWithRootObject(token)
				NSUserDefaults.standardUserDefaults().setObject(data, forKey: _accessTokenKey)
			} else {
				NSUserDefaults.standardUserDefaults().removeObjectForKey(_accessTokenKey)
			}
		}
	}

	static var user: ManagedUser?

	static func getClientCredentials(headers oauthHeaders : [String : String], callback : (success: Bool, accessToken : AccessToken?) -> () ) {

		let params = [ "client_id":Config.ClientId,
		               "grant_type":"client_credentials",
		               "client_secret": Config.ClientSecret]

		APIUtility.request(.POST, route: Config.APIRoutes.oauth, parameters: params, headers: oauthHeaders).responseJSON { (response) in

			var success : Bool = false
			var accessToken : AccessToken?

			switch response.result {
			case .Success:
				if let value = response.result.value {
					accessToken = AccessToken(json: JSON(value))
					success = true
				}
			case .Failure(_):
				success = false
			}
			callback(success: success, accessToken: accessToken)
		}
	}


	static func getTokenAssertion(headers oauthHeaders: [String : String], callback : (success : Bool, accessToken : AccessToken?) -> ()) {

		let params = [ "client_id":Config.ClientId,
		               "grant_type":"assertion"]

		APIUtility.request(.POST, route: Config.APIRoutes.oauth, parameters: params, headers: oauthHeaders).responseJSON { (response) in

			var accessToken : AccessToken?
			var success : Bool = false

			switch response.result {
			case .Success:
				if let value = response.result.value {
					accessToken = AccessToken(json: JSON(value))
				}
				success = accessToken != nil
			case .Failure(_):
				success = false
			}

			callback(success: success, accessToken: accessToken)
		}

	}

	static func signOut() {
		revokeToken(callback: nil)
		accessToken = nil
		DatabaseManager.sharedInstance.flushDatastore()
	}

	static func revokeToken(callback callback: ((success : Bool) -> ())?) {
		APIUtility.request(.POST, route: Config.APIRoutes.revoke, parameters: nil).responseJSON { (response) in
			switch response.result {
			case .Success:
				callback?(success: true)
			case .Failure(_):
				callback?(success: false)
			}
		}
	}

}
