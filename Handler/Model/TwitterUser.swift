//
//  TwitterUser+CoreDataClass.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 18/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData


extension TwitterUser {
	
	var onHandler : Bool { return user != nil }
	
	var following : Bool { return TwitterFollowStatus(rawValue: followStatus) == .following }
        
    convenience init(data: TwitterUserData, context: NSManagedObjectContext) {
        self.init(context: context)
        self.setTwitterUserData(data)
    }
    
    func setTwitterUserData(_ data : TwitterUserData) {
		
		identifier = data.identifier
		username = data.username
		name = data.name
		pictureURLString = data.pictureURLString
		desc = data.desc
		location = data.location
		followerCount = data.followerCount
		followStatus = TwitterFollowStatus.unknown.rawValue

		if let banner = data.bannerURLString {
			bannerURLString = banner
		}
		
		if let follow = data.following {
			followStatus = follow ? TwitterFollowStatus.following.rawValue : TwitterFollowStatus.notFollowing.rawValue
		}

    }
}

enum TwitterFollowStatus : Int16 {
	case notFollowing = 0
	case following = 1
	case unknown = 2
}
