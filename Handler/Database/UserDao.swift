//
//  UserManager.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 17/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

struct UserDao {
	
	static func findUserWithHandle(handle : String, context : NSManagedObjectContext = CoreDataStack.shared.viewContext) -> User? {
		let fetchRequest : NSFetchRequest<User> = User.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "twitterUser.username == %@", handle)
		fetchRequest.fetchBatchSize = 1
		return context.safeExecute(fetchRequest).first
	}
	
	static func updateOrCreateUser(userData : UserData, context : NSManagedObjectContext = CoreDataStack.shared.viewContext) -> User {
		let fetchRequest : NSFetchRequest<User> = User.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", userData.identifier!)
		fetchRequest.fetchBatchSize = 1
		
		if let user = context.safeExecute(fetchRequest).first {
			user.setUserData(userData)
			return user
		}
		let user = User(data: userData, context: context)
		user.twitterUser = updateOrCreateTwitterUser(twitterUserData: userData.twitterUser!, context : context)
		return user
	}
	
	static func updateOrCreateTwitterUser(twitterUserData : TwitterUserData, context : NSManagedObjectContext = CoreDataStack.shared.viewContext) -> TwitterUser {
		let fetchRequest : NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", twitterUserData.identifier!)
		fetchRequest.fetchBatchSize = 1
		
		if let twitterUser = context.safeExecute(fetchRequest).first {
			twitterUser.setTwitterUserData(twitterUserData)
			return twitterUser
		}
		let twitterUser = TwitterUser(data: twitterUserData, context: context)
		return twitterUser
	}
	
}
