//
//  Config.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 10/07/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

struct Config {

	static let ClientId = "61e5e9e14a8a79ab6d0e878a59fd610a54fb32dbc9121e4e527864f15f0feb03"
	static let ClientSecret = "206918bd632983a20cc5549ced836ea63fe80803b2ac3f95d044d06296932d75"

	static let APIURL = "http://handler-api-dev.eu-west-1.elasticbeanstalk.com/"
	static let APIVersion = "api/v1/"

	struct APIRoutes {
		//OAuth
		static let oauth = "oauth/token"

		//Messaging
		static let messages = Config.APIVersion + "messages"
		static let message = Config.APIVersion + "messages/:message_id"
		static func message(messageId : String) -> String {
			return message.stringByReplacingOccurrencesOfString(":message_id", withString: messageId)
		}

		static let user = Config.APIVersion + "users/:user_id"
		static func user(userId : String) -> String {
			return user.stringByReplacingOccurrencesOfString(":user_id", withString: userId)
		}
				
	}

	struct Twitter {
		static let consumerKey = "bH6FU5R4bVQ5QJhYvNyFZywFm"
		static let consumerSecret = "64VOfx9rmBBf98v7dNFQa9m4NEKsTpX82JSSyGlN5W4A4i8cTy"

//		static let consumerKey = "H39589t6PVVSCD9nLvPQnYoT6"
//		static let consumerSecret = "GPS9xgLaZ2NQ2ZCunX1AfnyzdP122vARdEGD6m4iJM08Cte9H0"
	}
}
