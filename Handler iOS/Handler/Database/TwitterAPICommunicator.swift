//
//  TwitterAPICommunicator.swift
//  Handler
//
//  Created by Christian Praiss on 16/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

let fetchedTwitterDataNotification = "fetchedTwitterDataNotification"

class TwitterAPICommunicator: NSObject {
	static let sharedInstance = TwitterAPICommunicator()
	
	var friendIDS: [String] = [String]()
	var followerIDS: [String] = [String]()
	
	func getTwitterData(){
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
	
	class func getAccountInfoForTwitterUser(handle: String, callback: (user: JSON?, erorr: NSError?)->Void){
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
	
	class func followStatusForID(id: String)->TwitterFriendshipStatus{
		for friendID in sharedInstance.friendIDS {
			if(friendID == id){
				return .Following
			}
		}
		
		for followerID in sharedInstance.followerIDS {
			if(followerID == id){
				return .Follower
			}
		}
		
		return .Unknown
	}
}
