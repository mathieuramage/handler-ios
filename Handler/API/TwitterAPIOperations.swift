//
//  TwitterAPIOperations.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 09/09/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

let fetchedTwitterDataNotification = "fetchedTwitterDataNotification"

struct TwitterAPIOperations {

	static let sharedInstance = TwitterAPIOperations()

	static var friendIDS: [String] = [String]()
	static var followerIDS: [String] = [String]()

	static func getTwitterData() {

		if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {

			let client = TWTRAPIClient(userID: session.userID)
			let friendsEndpoint = "https://api.twitter.com/1.1/friends/ids.json"
			let params = ["stringify_ids": "true"]

			let request = client.URLRequestWithMethod("GET", URL: friendsEndpoint, parameters: params, error: nil)

			client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
				guard let error = connectionError else {
					if let data = data {
						let json = JSON(data).arrayValue.map{$0.stringValue}
						self.friendIDS = json
						NSNotificationCenter.defaultCenter().postNotificationName(fetchedTwitterDataNotification, object: nil)
					}
					return
				}
				print(error)
			}

			let followersEndpoint = "https://api.twitter.com/1.1/followers/ids.json"

			let secondrequest = client.URLRequestWithMethod("GET", URL: followersEndpoint, parameters: params, error: nil)

			client.sendTwitterRequest(secondrequest) { (response, data, connectionError) -> Void in
				guard let error = connectionError else {
					if let data = data {
						let json = JSON(data).arrayValue.map{$0.stringValue}
						self.followerIDS = json
						NSNotificationCenter.defaultCenter().postNotificationName(fetchedTwitterDataNotification, object: nil)
					}
					return
				}
				print(error)
			}
		}
	}

	static func getAccountInfoForTwitterUser(handle: String, callback: (user: JSON?, erorr: NSError?)->Void){
		if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {
			let client = TWTRAPIClient(userID: session.userID)
			let endPoint = "https://api.twitter.com/1.1/users/show.json"
			let params = ["screen_name": handle]

			let request = client.URLRequestWithMethod("GET", URL: endPoint, parameters: params, error: nil)

			client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
				guard let error = connectionError else {
					if let data = data {
						do {
							let dict = try NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.AllowFragments])
							let json = JSON(dict)
							callback(user:json, erorr: nil)
						}catch {
							return
						}
					}
					return
				}
				callback(user: nil, erorr: error)
				print(error)
			}
		}
	}


	static func getTwitterFriends(cursor : Int?, callback : (users : [TwitterUser], nextCursor : Int?) -> ()) {

		if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {

			let client = TWTRAPIClient(userID: session.userID)
			let friendsEndpoint = "https://api.twitter.com/1.1/friends/list.json"

			let params : [String : AnyObject]
			if let cursor = cursor {
				params = ["cursor" : "\(cursor)"]
			} else {
				params = [:]
			}

			let request = client.URLRequestWithMethod("GET", URL: friendsEndpoint, parameters: params, error: nil)

			client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in

				guard connectionError == nil, let data = data else {
					callback(users: [], nextCursor: nil)
					return
				}
				do {
					let dict = try NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.AllowFragments])
					let json = JSON(dict)
					var users : [TwitterUser] = []
					for userJson in json["users"].arrayValue {
						let user = TwitterUser(twitterAPIJson: userJson)
						users.append(user)
					}
					let nextCursor = json["next_cursor"].int
					callback(users:users, nextCursor: nextCursor)
				}catch {
					callback(users: [], nextCursor: nil)
					return
				}
			}

		}
	}


	static func getTwitterFollowers(cursor : Int?, callback : (users : [TwitterUser], nextCursor : Int?) -> ()) {

		if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {

			let client = TWTRAPIClient(userID: session.userID)
			let friendsEndpoint = "https://api.twitter.com/1.1/followers/list.json"

			let params : [String : AnyObject]
			if let cursor = cursor {
				params = ["cursor" : "\(cursor)"]
			} else {
				params = [:]
			}

			let request = client.URLRequestWithMethod("GET", URL: friendsEndpoint, parameters: params, error: nil)

			client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in

				guard connectionError == nil, let data = data else {
					callback(users: [], nextCursor: nil)
					return
				}
				do {
					let dict = try NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.AllowFragments])
					let json = JSON(dict)
					var users : [TwitterUser] = []
					for userJson in json["users"].arrayValue {
						let user = TwitterUser(twitterAPIJson: userJson)
						users.append(user)
					}
					let nextCursor = json["next_cursor"].int
					callback(users:users, nextCursor: nextCursor)
				}catch {
					callback(users: [], nextCursor: nil)
					return
				}
			}

		}
	}

	static func followStatusForID(id: String)->TwitterFriendshipStatus{
		for friendID in friendIDS {
			if(friendID == id){
				return .Following
			}
		}

		for followerID in followerIDS {
			if(followerID == id){
				return .Follower
			}
		}
		return .Unknown
	}

}
