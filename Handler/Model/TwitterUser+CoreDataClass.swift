//
//  TwitterUser+CoreDataClass.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 18/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData


public class TwitterUser: NSManagedObject {
    
    convenience init(data : TwitterUserData, context : NSManagedObject) {
        
    }
    
    convenience init(data: TwitterUserData, context: NSManagedObjectContext) {
        self.init(managedObjectContext: context)
        TwitterUser.setTwitterUserData(user: self, data: data)
    }
    
    class func setTwitterUserData(user : User, data : TwitterUserData) {
        user.identifier = data.identifier
        user.createdAt = (data.createdAt as? NSDate)
        user.updatedAt = (data.updatedAt as? NSDate)
    }
    
    
    func setTwitterUserData(_ data : UserData) {
        User.setUserData(user : self, data : data)
    }
    
}
