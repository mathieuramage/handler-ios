//
//  UserOperations.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/06/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

struct UserOperations {

	static func getMe(callback: (success : Bool, user : User?) -> ()) {
		getUser("me", callback: callback)
	}

	static func getUser(screenName : String, callback : (success : Bool, user : User?) -> ()) {
		let route = Config.APIRoutes.user("me")

		APIUtility.request(.GET, route: route, parameters: nil).responseJSON { (response) in
			switch response.result {
			case .Success:
				var user : User?
				if let value = response.result.value {
					user = User(json: JSON(value))
				}
				callback(success: user != nil, user: user)

			case .Failure(_):
				callback(success: false, user: nil)
			}
		}
	}

	static func addDevice() {
		
	}
	
}
