//
//  User+CoreDataClass.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 18/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


extension User {
    
    var handle : String {
        return twitterUser?.username ?? ""
    }
    
    var name : String {
        return twitterUser?.name ?? ""
    }
    
    var pictureUrl : URL? {
        if let pictureUrlString = twitterUser?.pictureURLString {
            return URL(string: pictureUrlString)
        }
        return nil
    }
    
    var bannerUrl : URL? {
        if let bannerUrlString = twitterUser?.bannerURLString {
            return URL(string: bannerUrlString)
        }
        return nil
    }
    
    convenience init(data: UserData, context: NSManagedObjectContext) {
        self.init(context: context)
        self.setUserData(data)
    }
    
    func setUserData(_ data : UserData) {
		identifier = data.identifier
		createdAt = data.createdAt?.NSDateValue
		updatedAt = data.updatedAt?.NSDateValue
	}
}
