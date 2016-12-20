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


public class User: NSManagedObject {
    
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
        self.init(managedObjectContext: context)
        User.setUserData(user: self, data: data)
    }
    
    class func setUserData(user : User, data : UserData, twitterUser : TwitterUser? = nil) {
        user.identifier = data.identifier
        user.createdAt = (data.createdAt as? NSDate)
        user.updatedAt = (data.updatedAt as? NSDate)
    }
    
    
    func setUserData(_ data : UserData) {
        User.setUserData(user : self, data : data)
    }
    
//    convenience init(handle: String, inManagedContext context: NSManagedObjectContext) {
//        // OTTODO: Implement this
//        self.init(managedObjectContext: context)
//    }
//    
//    class func userWithJSON(_ json: JSON, inContext context: NSManagedObjectContext) -> User {
//        let identifier = json["twitter"]["id"].stringValue
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
//        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
//        fetchRequest.fetchBatchSize = 1
//        
//        if let user = (context.safeExecuteFetchRequest(fetchRequest) as [User]).first as User? {
//            return user
//        }
//        
//        let user = User(json: json, inContext: context)
//        
//        return user
//    }
//    
//    class func fetchRequestForHandle(_ handle: String) -> NSFetchRequest<NSFetchRequestResult> {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
//        fetchRequest.predicate = NSPredicate(format: "%K == %@", "handle", handle)
//        return fetchRequest
//    }

}
