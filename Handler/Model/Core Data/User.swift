//
//  User.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 16/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

public class User: NSManagedObject {
    
    var pictureUrl : URL? {
        if let pictureUrlString = profile_picture_url {
            return URL(string: pictureUrlString)
        }
        return nil
    }
    
    convenience init(json: JSON, inContext context: NSManagedObjectContext) {
        self.init(managedObjectContext: context)
        identifier = json["twitter"]["id"].stringValue
        
        let twitterJson = json["twitter"]
        
        twitterUser = TwitterUser(json: twitterJson, inContext: context)
        
        profile_picture_url = json["twitter"]["pictureUrl"].stringValue
        handle = json["twitter"]["username"].stringValue
        name = json["twitter"]["name"].stringValue
    }

}
