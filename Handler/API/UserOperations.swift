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

	static func getMe(_ callback: @escaping (_ success : Bool, _ user : ManagedUser?) -> ()) {
		getUser("me", callback: callback)
	}

	static func getUser(_ screenName : String, callback : @escaping (_ success : Bool, _ user : ManagedUser?) -> ()) {
		let route = Config.APIRoutes.user(screenName)

		APIUtility.request(method: .get, route: route, parameters: nil).responseJSON { (response) in
			switch response.result {
			case .success:
				var user : ManagedUser?
				if let value = response.result.value {
					user = ManagedUser.userWithJSON(JSON(value)["data"], inContext:PersistenceManager.mainManagedContext)
				}
				callback(user != nil, user)
			case .failure(_):
				callback(false, nil)
			}
		}
	}

	static func addDevice() {
		
	}
	
}
