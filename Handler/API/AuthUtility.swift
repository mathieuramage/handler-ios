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

class AuthUtility {
	
	static let shared = AuthUtility()
	
	private init() {}
	
	private let _accessTokenKey = "HR_ACCESS_TOKEN_KEY"
	private var _accessToken : AccessToken?
	
	var accessToken : AccessToken? {
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
	
	private let _appUserNameKey = "HR_APP_USER_KEY"
	private var _appUser : User?
	
	var user: User? {
		get {
			if let appUser = _appUser {
				return appUser
			}
			
			if let username = UserDefaults.standard.object(forKey: _appUserNameKey) as? String {
				_appUser = UserDao.findUserWithHandle(handle: username)
			}
			return _appUser
		}
		
		set {
			if let appUser = newValue {
				_appUser = appUser
				UserDefaults.standard.set(appUser.handle, forKey: _appUserNameKey)
			} else {
				UserDefaults.standard.removeObject(forKey: _appUserNameKey)
			}
		}
	}
	
	
	func signOut() {
		UserOperations.revokeToken(callback: nil)
		accessToken = nil
		user = nil
		Intercom.reset()
		CoreDataStack.shared.flushDatastore()
	}
	



}
