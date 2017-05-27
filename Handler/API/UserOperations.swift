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
	
	init(user : User?) {
		identifier = user?.identifier
		isContact = (user?.isContact ?? nil)!
	}
	
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
