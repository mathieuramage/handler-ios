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

			let request = client.urlRequest(withMethod: "GET", url: friendsEndpoint, parameters: params, error: nil)

			client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
				guard let error = connectionError else {
					if let data = data {
						let json = JSON(data).arrayValue.map{$0.stringValue}
						self.friendIDS = json
						NotificationCenter.default.post(name: Notification.Name(rawValue: fetchedTwitterDataNotification), object: nil)
					}
					return
				}
				print(error)
			}

			let followersEndpoint = "https://api.twitter.com/1.1/followers/ids.json"

			let secondrequest = client.urlRequest(withMethod: "GET", url: followersEndpoint, parameters: params, error: nil)

			client.sendTwitterRequest(secondrequest) { (response, data, connectionError) -> Void in
				guard let error = connectionError else {
					if let data = data {
						let json = JSON(data).arrayValue.map{$0.stringValue}
						self.followerIDS = json
						NotificationCenter.default.post(name: Notification.Name(rawValue: fetchedTwitterDataNotification), object: nil)
					}
					return
				}
				print(error)
			}
		}
	}

	static func getAccountInfoForTwitterUser(_ handle: String, callback: @escaping (_ user: JSON?, _ error: Error?)->Void){
		if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {
			let client = TWTRAPIClient(userID: session.userID)
			let endPoint = "https://api.twitter.com/1.1/users/show.json"
			let params = ["screen_name": handle]

			let request = client.urlRequest(withMethod: "GET", url: endPoint, parameters: params, error: nil)

			client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
				guard let error = connectionError else {
					if let data = data {
						do {
							let dict = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments])
							let json = JSON(dict)
							callback(json,nil)
						}catch {
							return
						}
					}
					return
				}
				callback(nil, error)
				print(error)
			}
		}
	}


	static func getTwitterFriends(_ cursor : Int?, callback : @escaping (_ users : [TwitterUserData], _ nextCursor : Int?) -> ()) {

		if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {

			let client = TWTRAPIClient(userID: session.userID)
			let friendsEndpoint = "https://api.twitter.com/1.1/friends/list.json"

			let params : [String : AnyObject]
			if let cursor = cursor {
				params = ["cursor" : "\(cursor)" as AnyObject,
				"count" : "200" as AnyObject]
			} else {
				params = ["count" : "200" as AnyObject]
			}
			let request = client.urlRequest(withMethod: "GET", url: friendsEndpoint, parameters: params, error: nil)

			client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in

				guard connectionError == nil, let data = data else {
					callback([], nil)
					return
				}
				do {
					let dict = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments])
					let json = JSON(dict)
					var users : [TwitterUserData] = []
					for userJson in json["users"].arrayValue {
						let user = TwitterUserData(twitterAPIJson: userJson)
						users.append(user)
					}
					let nextCursor = json["next_cursor"].int
					callback(users, nextCursor)
				}catch {
					callback([], nil)
					return
				}
			}

		}
	}


	static func getTwitterFollowers(_ cursor : Int?, callback : @escaping (_ users : [TwitterUserData], _ nextCursor : Int?) -> ()) {

		if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {

			let client = TWTRAPIClient(userID: session.userID)
			let friendsEndpoint = "https://api.twitter.com/1.1/followers/list.json"

			let params : [String : AnyObject]
			if let cursor = cursor {
				params = ["cursor" : "\(cursor)" as AnyObject,
				          "count" : "200" as AnyObject]
			} else {
				params = ["count" : "200" as AnyObject]
			}

			let request = client.urlRequest(withMethod: "GET", url: friendsEndpoint, parameters: params, error: nil)

			client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in

				guard connectionError == nil, let data = data else {
					callback([], nil)
					return
				}
				do {
					let dict = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments])
					let json = JSON(dict)
					var users : [TwitterUserData] = []
					for userJson in json["users"].arrayValue {
						let user = TwitterUserData(twitterAPIJson: userJson)
						users.append(user)
					}
					let nextCursor = json["next_cursor"].int
					callback(users, nextCursor)
				}catch {
					callback([], nil)
					return
				}
			}

		}
	}

	static func followStatusForID(_ id: String)->TwitterFriendshipStatus{
		for friendID in friendIDS {
			if(friendID == id){
				return .following
			}
		}

		for followerID in followerIDS {
			if(followerID == id){
				return .follower
			}
		}
		return .unknown
	}

}
