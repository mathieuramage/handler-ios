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
	var expiresIn : TimeInterval
	var createdAt: Date

	init(json : JSON) {
		token = json["access_token"].stringValue
		type = json["token_type"].stringValue
		expiresIn = json["expires_in"].doubleValue
		createdAt = Date()
		if let dateStr = json["created_at"].string {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			createdAt = formatter.date(from: dateStr)!
		}
	}

	init(coder aDecoder: NSCoder) {
		token = aDecoder.decodeObject(forKey: "token") as! String
		type = aDecoder.decodeObject(forKey: "type") as! String
		expiresIn = aDecoder.decodeDouble(forKey: "expiresIn")
		createdAt = aDecoder.decodeObject(forKey: "createdAt") as! Date

	}

	func encodeWithCoder(_ aCoder: NSCoder) {
		aCoder.encode(token, forKey: "token")
		aCoder.encode(type, forKey: "type")
		aCoder.encode(expiresIn, forKey: "expiresIn")
		aCoder.encode(createdAt, forKey: "createdAt")
	}
}
