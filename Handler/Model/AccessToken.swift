//
//  AccessToken.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 07/08/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class AccessToken: NSObject {

	var token : String
	var type : String
	var expiresIn : NSTimeInterval
	var createdAt: NSDate

	init(json : JSON) {
		token = json["access_token"].stringValue
		type = json["token_type"].stringValue
		expiresIn = json["expires_in"].doubleValue
		createdAt = NSDate()
		if let dateStr = json["created_at"].string {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			createdAt = formatter.dateFromString(dateStr)!
		}
	}

	init(coder aDecoder: NSCoder) {
		token = aDecoder.decodeObjectForKey("token") as! String
		type = aDecoder.decodeObjectForKey("type") as! String
		expiresIn = aDecoder.decodeDoubleForKey("expiresIn")
		createdAt = aDecoder.decodeObjectForKey("createdAt") as! NSDate

	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(token, forKey: "token")
		aCoder.encodeObject(type, forKey: "type")
		aCoder.encodeDouble(expiresIn, forKey: "expiresIn")
		aCoder.encodeObject(createdAt, forKey: "createdAt")
	}
}
