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

/*
{
    "_id": "57a5db8371f744a56964f79e",
    "updatedAt": "2016-08-07T16:48:59.670Z",
    "createdAt": "2016-08-06T12:43:47.909Z",
    "__v": 0,
    "processing": "success",
    "emailThreads": 0,
    "noProfileLocation": true,
    "deactivatedOn": null,
    "blockedOn": null,
    "tenRatingSince": null,
    "fiveRatingSince": null,
    "threeRatingSince": null,
    "flags": [],
    "userStatus": "active",
    "riskRating": 0,
    "role": "user",
    "_devices": ["57a5db8471f744a56964f79f", "57a7667b71f744a56964f7db"],
    "twitter": {
        "id": "75622435",
        "username": "calt",
        "name": "Cagdas Altinkaya",
        "createdAt": "2009-09-19T19:26:36.000Z",
        "pictureUrl": "https://pbs.twimg.com/profile_images/3491234935/928fa17b98b037196646bc378d245f55_normal.jpeg",
        "description": "Dev Lead @ http://t.co/seMNnwTPna | iOS & Web Dev | Loves guitars & gadgets",
        "tweetsCount": 660,
        "location": "Istanbul",
        "followersCount": 113
    },
    "shield": {
        "handler": {
            "ratioResponseToSent2Days": 6,
            "flags": 0,
            "emailThreads": 4,
            "createdAt": 122
        },
        "twitter": {
            "ratioTweetsPerCreationDay": 0,
            "ratioFollowersToFollowing": null,
            "noProfileLocation": false,
            "noProfileDescription": false,
            "noProfilePicture": false,
            "createdAt": 2635
        }
    }
*/

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
    var following: Bool
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
