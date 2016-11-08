//
//  TwitterUser.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 09/09/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON


	/* Android mapping
@SerializedName(value="id", alternate={"id_str"})
public String id  = "";
public String name  = "";
@SerializedName(value="username", alternate={"screen_name"})
public String username  = "";
@SerializedName(value="pictureUrl", alternate={"profile_image_url"})
public String pictureUrl = "";
public String description  = "";
public String location  = "";
public boolean verified;
@SerializedName(value="banner", alternate={"profile_banner_url"})
public String banner  = "";
public String url  = "";
@SerializedName(value="followersCount", alternate={"followers_count"})
public int followersCount;
@SerializedName(value="friendsCount", alternate={"friends_count"})
public int friendsCount;
*/

/*
"id": "1151830309",
"username": "SikmaGercekler",
"name": "Sıkma Gerçekler",
"createdAt": "2013-02-05T19:44:55.000Z",
"pictureUrl": "https://pbs.twimg.com/profile_images/3213135322/b68ee0ac6de30eb82ad2a7d1b705948e_normal.jpeg",
"description": "Külliyen yalan.",
"tweetsCount": 14,
"location": "",
"followersCount": 123
*/

class TwitterUser: NSObject {

	var identifier : String
	var username : String?
	var name : String?
	var pictureURL : URL?
	var desc : String?
	var location : String?
	var bannerURL : URL?
	var url : URL?
	var followerCount : Int?
	var friendCount : Int?
	var following : Bool?

	init(json : JSON) {
		identifier = json["id"].stringValue
		username = json["username"].string
		if let twitterPictureUrlStr = json["pictureUrl"].string {
			pictureURL = URL(string: twitterPictureUrlStr)
		}
		followerCount = json["followersCount"].int
		desc = json["desc"].string
	}

	init(twitterAPIJson : JSON) {
		identifier = ""
		username = twitterAPIJson["screen_name"].stringValue
		name = twitterAPIJson["name"].stringValue
		let unescapedUrl = twitterAPIJson["profile_image_url_https"].stringValue as NSString
		pictureURL = URL(string :unescapedUrl.replacingOccurrences(of: "\\", with: "", options: .literal, range: NSMakeRange(0, unescapedUrl.length)))
		following = twitterAPIJson["following"].boolValue
	}
}
