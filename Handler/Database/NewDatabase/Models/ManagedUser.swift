//
//  User.swift
//
//
//  Created by Otávio on 18/09/16.
//
//

import Foundation
import CoreData
import SwiftyJSON

class ManagedUser: NSManagedObject {
    
    var pictureUrl : URL? {
        if let pictureUrlString = profile_picture_url {
            return URL(string: pictureUrlString)
        }
        return nil
    }
    
    fileprivate convenience init(json: JSON, inContext context: NSManagedObjectContext) {
        self.init(managedObjectContext: context)
        identifier = json["twitter"]["id"].stringValue
        profile_picture_url = json["twitter"]["pictureUrl"].stringValue
        handle = json["twitter"]["username"].stringValue
        name = json["twitter"]["name"].stringValue

    }
    
    fileprivate convenience init(handle: String, inManagedContext context: NSManagedObjectContext) {
        // OTTODO: Implement this
        self.init(managedObjectContext: context)
    }
    
    class func userWithJSON(_ json: JSON, inContext context: NSManagedObjectContext) -> ManagedUser {
        let identifier = json["twitter"]["id"].stringValue
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        fetchRequest.fetchBatchSize = 1

        if let user = (context.safeExecuteFetchRequest(fetchRequest) as [ManagedUser]).first as ManagedUser? {
            return user
        }
        
        let user = ManagedUser(json: json, inContext: context)
        
        return user
    }
    
    
    class func userWithHandle(_ handle: String, inContext context: NSManagedObjectContext? = nil) -> ManagedUser {
        let internalContext = context ?? DatabaseManager.sharedInstance.mainManagedContext
        
        if let user = (internalContext.safeExecuteFetchRequest(ManagedUser.fetchRequestForHandle(handle)) as [ManagedUser]).first {
            return user
        }
        else {
            return ManagedUser(handle: handle, inManagedContext: internalContext)
        }
    }
    
    class func fetchRequestForHandle(_ handle: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "handle", handle)
        return fetchRequest
    }
}
