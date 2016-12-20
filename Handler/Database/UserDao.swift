//
//  UserDao.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 17/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

struct UserDao {
    
    static func fetchRequestForHandle(_ handle: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "handle", handle)
        return fetchRequest
    }
    
    static func updateOrCreateUser(userData : UserData) -> User {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityName())
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", userData.identifier!)
        fetchRequest.fetchBatchSize = 1
        
        if let user = (PersistenceManager.mainManagedContext.safeExecuteFetchRequest(fetchRequest) as [User]).first as User? {
            user.setUserData(userData)
            return user
        }
        
        let user = User(data: userData, context: PersistenceManager.mainManagedContext)
        return user
    }
    
    static func findUserWithHandle(_ handle: String, inContext context: NSManagedObjectContext? = nil) -> User? {
        let internalContext = context ?? PersistenceManager.mainManagedContext
        
        if let user = (internalContext.safeExecuteFetchRequest(fetchRequestForHandle(handle)) as [User]).first {
            return user
        }
        return nil
    }
    
}
