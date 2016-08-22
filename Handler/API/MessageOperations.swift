//
//  MessageOperations.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/06/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

struct MessageOperations {

	static func getAllMessages(before before : NSDate? , after : NSDate?, limit : Int?, callback : (success : Bool, messages : [Message]?) -> ()) {

		var params : [String : AnyObject] = [:]

		if let before = before {
			params["before"] = Int(before.timeIntervalSince1970 * 1000)
		} else {
			params["before"] = NSDate()
		}
		if let after = after {
			params["after"] =  Int(after.timeIntervalSince1970 * 1000)
		} else {
			params["after"] = 0
		}

		if let limit = limit {
			params["limit"] = limit
		}

		APIUtility.request(.GET, route: Config.APIRoutes.messages, parameters: params).responseJSON { (response) in

			switch response.result {
			case .Success:
				var messages : [Message] = []
				if let value = response.result.value {
					if let json = JSON(value)["messages"].array {
						for messageJson in json {
							let message = Message(json: messageJson)
							messages.append(message)
						}
					}
				}
				callback(success: true, messages: messages)
			case .Failure(_):
				callback(success: false, messages: nil)
			}
		}

	}


	static func getMessage(id : String, callback : (success : Bool, message : Message?) -> ()) {
		
		let route = Config.APIRoutes.message(id)
		APIUtility.request(.GET, route: route, parameters: nil).responseJSON { (response) in
			switch response.result {
			case .Success:
				var message : Message?
				if let value = response.result.value {
					message = Message(json: JSON(value))
				}
				callback(success: true, message: message)
			case .Failure(_):
				callback(success: false, message: nil)
			}
		}

	}


	static func updateMessage() {

	}


	static func updateConversation() {
		
	}

}
