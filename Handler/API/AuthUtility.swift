//
//  AuthUtility.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 10/07/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Intercom

struct AuthUtility {
	fileprivate static let _accessTokenKey = "HR_ACCESS_TOKEN_KEY"
	fileprivate static var _accessToken : AccessToken?
	static var accessToken : AccessToken? {
		get {
			if let token = _accessToken {
				return token
			} else {
				if let data = UserDefaults.standard.object(forKey: _accessTokenKey) as? Data {
					_accessToken = NSKeyedUnarchiver.unarchiveObject(with: data) as? AccessToken
				}
				return _accessToken
			}
		}
		set {
			if let token = newValue {
				_accessToken = token
				let data = NSKeyedArchiver.archivedData(withRootObject: token)
				UserDefaults.standard.set(data, forKey: _accessTokenKey)
			} else {
				UserDefaults.standard.removeObject(forKey: _accessTokenKey)
			}
		}
	}

	static var user: ManagedUser?

	static func getClientCredentials(headers oauthHeaders : [String : String], callback : @escaping (_ success: Bool, _ accessToken : AccessToken?) -> () ) {

		let params = [ "client_id":Config.ClientId,
		               "grant_type":"client_credentials",
		               "client_secret": Config.ClientSecret]

		APIUtility.request(method: .post, route: Config.APIRoutes.oauth, parameters: params, headers: oauthHeaders).responseJSON { (response) in

			var success : Bool = false
			var accessToken : AccessToken?

			switch response.result {
			case .success:
				if let value = response.result.value {
					accessToken = AccessToken(json: JSON(value))
					success = true
				}
			case .failure(_):
				success = false
			}
			callback(success, accessToken)
		}
	}


	static func getTokenAssertion(headers oauthHeaders: [String : String], callback : @escaping (_ success : Bool, _ accessToken : AccessToken?) -> ()) {

        let params : [String : Any] = [ "client_id": Config.ClientId,
		               "grant_type":"assertion"]

        APIUtility.request(method: .post, route: Config.APIRoutes.oauth, parameters: params, headers: oauthHeaders).responseJSON { (response) in

			var accessToken : AccessToken?
			var success : Bool = false

			switch response.result {
			case .success:
				if let value = response.result.value {
					accessToken = AccessToken(json: JSON(value))
				}
				success = accessToken != nil
			case .failure(_):
				success = false
			}

			callback(success, accessToken)
		}

	}

	static func signOut() {
		revokeToken(callback: nil)
		accessToken = nil
		UserDefaults.standard.set(nil, forKey: Config.UserDefaults.uidKey)
		Intercom.reset()
		DatabaseManager.sharedInstance.flushDatastore()
	}

	static func revokeToken(callback: ((_ success : Bool) -> ())?) {
        APIUtility.request(method: .post, route: Config.APIRoutes.revoke, parameters: nil).responseJSON { (response) in
			switch response.result {
			case .success:
				callback?(true)
			case .failure(_):
				callback?(false)
			}
		}
	}

}
