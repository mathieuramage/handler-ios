//
//  User.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/06/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject {

	/*
	twitter.id	String	Required | Unique
	twitter.username	String	# Can be empty
	twitter.name	String	# Can be empty
	twitter.pictureUrl	String	# Can be empty
	twitter.description	String	# Can be empty
	devices	ObjectID	# Can be empty
	friendsCount	Number	# Can be empty
	role	String	Required | Default: ‘draft’ | Enum: ['inbox', 'sent', 'archived', 'deleted', 'draft']
	riskRating	Number	Default: 0
	userStatus	String	Required | Default: ‘active’ | Enum: ['active', 'deactivated', 'blocked']
	flags.createdAt	Date	# Can be empty
	flags.createdBy	User	# Can be empty
	threeRatingSince	Date	# Can be empty
	fiveRatingSince	Date	# Can be empty
	tenRatingSince	Date	# Can be empty
	blockedOn	Date	# Can be empty
	deactivatedOn	Date	# Can be empty
	noProfileLocation	Boolean	Default: true
	emailThreads	Number	Default: 0
	signInsSimultaneous	Number	Default: 1

	*/

	var identifier : String

	var twitterId : String
	var twitterUserName : String?
	var twitterPictureUrl : NSURL?
	var twitterDescription : String?

	var devices : [String]? //??
	var friendsCount : Int?
	var role : String?
	var riskRating : Int
	var status : UserStatus
	//TODO
	var emailThreadCount : Int

	init(json : JSON) {
		identifier = json["_id"].stringValue
		twitterId = json["twitter"]["id"].stringValue
		twitterUserName = json["twitter"]["username"].string
		if let twitterPictureUrlStr = json["twitter"]["pictureUrl"].string {
			twitterPictureUrl = NSURL(string: twitterPictureUrlStr)
		}

		friendsCount = json["friendsCount"].int
		role = json["role"].string
		riskRating = json["riskRating"].intValue

		status = UserStatus(rawValue: json["userStatus"].stringValue)!

		//flags?
		emailThreadCount = json["emailThreads"].intValue
	}
	
}


enum UserStatus : String {
	case Active = "active"
	case Deactivated = "deactivated"
	case Blocked = "blocked"
}
