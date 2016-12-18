//
//  TwitterUser.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 16/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


public class TwitterUser: NSManagedObject {
    
    init(json : JSON, inContext:NSManagedObjectContext) {
        identifier = json["id"].stringValue
        username = json["username"].string
        pictureURL = json["pictureUrl"].string
        
        followerCount = json["followersCount"].int as NSNumber?
        desc = json["desc"].string
    }
    
    init(twitterAPIJson : JSON, inContext:NSManagedObjectContext) {
        identifier = ""
        username = twitterAPIJson["screen_name"].stringValue
        name = twitterAPIJson["name"].stringValue
        let unescapedUrl = twitterAPIJson["profile_image_url_https"].stringValue as NSString
        pictureURL = unescapedUrl.replacingOccurrences(of: "\\", with: "", options: .literal, range: NSMakeRange(0, unescapedUrl.length))
        following = twitterAPIJson["following"].boolValue as NSNumber?
    }

}
