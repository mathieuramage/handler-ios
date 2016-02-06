//
//  User.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import HandlerSDK

final class User: NSManagedObject, CoreDataConvertible {
	
	typealias HRType = HRUser
	
	required convenience init(hrType user: HRType, managedObjectContext: NSManagedObjectContext){
		self.init(managedObjectContext: managedObjectContext)
        
		self.updateFromHRType(user)
	}
	
	func updateFromHRType(user: HRType) {
        self.id = user.id
        self.desc = user.desc
        self.handle = user.handle
        self.name = user.name
        self.profile_picture_url = user.picture_url
        self.provider = user.provider
        self.created_at = NSDate.fromString(user.created_at)
        self.updated_at = NSDate.fromString(user.updated_at)
        self.twtterFollowStatus = NSNumber(integer: TwitterAPICommunicator.followStatusForID(user.name).rawValue)
	}
	
	func toHRType() -> HRUser {
		let user = HRUser()
		user.id = self.id ?? ""
		user.desc = self.desc ?? ""
		user.handle = self.handle ?? ""
		user.name = self.name ?? ""
		user.picture_url = self.profile_picture_url ?? ""
		user.provider = self.provider ?? ""
		user.created_at = NSDate.toString(self.created_at) ?? ""
		user.updated_at = NSDate.toString(self.updated_at) ?? ""
		return user
	}
	
	class func me()->User?{
		if let user = HRUserSessionManager.sharedManager.currentUser {
			return User.fromHRType(user)
		}else{
			return nil
		}
	}
	
	class func fromHandle(handle: String)->User{
		if let user = (MailDatabaseManager.sharedInstance.executeBackgroundFetchRequest(User.backgroundFetchRequestForHandle(handle)) as? [User])?.first {
			return user
		}else{
			let user = HRUser()
			user.handle = handle
			return User(hrType: user, managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
		}
	}
	
	static func backgroundFetchRequestForHandle(handle: String) -> NSFetchRequest {
		let fetchRequest = NSFetchRequest(entityName: self.entityName())
		fetchRequest.predicate = NSPredicate(format: "%K == %@", "handle", handle)
		return fetchRequest
	}
}
