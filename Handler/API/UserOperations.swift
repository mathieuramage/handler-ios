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
	
	
	static func getMe(_ callback: @escaping (_ success : Bool, _ user : UserData?) -> ()) {
		getUser("me", callback: callback)
	}
	
	static func getUser(_ screenName : String, callback : @escaping (_ success : Bool, _ user : UserData?) -> ()) {
		let route = Config.APIRoutes.user(screenName)
		APIUtility.request(method: .get, route: route, parameters: nil).responseJSON { (response) in
			switch response.result {
			case .success:
				var user : UserData?
				if let value = response.result.value {
					user = UserData(json: JSON(value)["data"])
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


struct UserData {	
	var createdAt: Date?
	var identifier: String?
	var isContact: Bool
	var riskRating: NSNumber?
	var twitterFollowStatus: NSNumber?
	var updatedAt: Date?
	var twitterUser: TwitterUserData?
	
	init(json : JSON) {
		identifier = json["id"].string
		if let createdAtStr = json["createdAt"].string {
			createdAt = Date.fromUTCString(createdAtStr)
		}
		if let updatedAtStr = json["updatedAt"].string {
			updatedAt = Date.fromUTCString(updatedAtStr)
		}
		twitterUser = TwitterUserData(json: json["twitter"])
		isContact = false
		riskRating = json["riskRating"].number
	}
}


struct TwitterUserData {
	
	var bannerURLString: String?
	var desc: String?
	var followerCount: NSNumber?
	var following: Bool?
	var friendCount: NSNumber?
	var identifier: String?
	var location: String?
	var name: String?
	var pictureURLString: String?
	var username: String?
	var urlString: String?
	var twitterId: String?
	var followStatus: NSNumber?
	
	
	init(json : JSON) {
		identifier = json["id"].string
		name = json["name"].string
		username = json["username"].stringValue
		pictureURLString = json["pictureUrl"].stringValue
		desc = json["description"].string
		followStatus = 0
		following = false // TODO
	}
	
	init(twitterAPIJson : JSON) {
		identifier = ""
		username = twitterAPIJson["screen_name"].stringValue
		name = twitterAPIJson["name"].stringValue
		let unescapedUrl = twitterAPIJson["profile_image_url_https"].stringValue as NSString
		pictureURLString = unescapedUrl.replacingOccurrences(of: "\\", with: "", options: .literal, range: NSMakeRange(0, unescapedUrl.length))
		following = twitterAPIJson["following"].boolValue
	}
}
