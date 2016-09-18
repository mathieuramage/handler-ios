//
//  User.swift
//  
//
//  Created by Otávio on 18/09/16.
//
//

import Foundation
import CoreData

class ManagedUser: NSManagedObject {

	convenience init(managedObjectContext: NSManagedObjectContext) {
		let entityName = self.dynamicType.entityName()
		let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)!
		self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
	}

	convenience init(user: User, inManagedContext context: NSManagedObjectContext) {
		// OTTODO: Implement this

		self.init(managedObjectContext: context)
	}

	convenience init(handle: String, inManagedContext context: NSManagedObjectContext) {
		// OTTODO: Implement this
		
		self.init(managedObjectContext: context)
	}

	class func me() -> ManagedUser? {
		// OTTODO: Implement this

		return nil
	}

	class func userWithHandle(handle: String, inContext context: NSManagedObjectContext? = nil) -> ManagedUser {
		let internalContext = context ?? DatabaseManager.sharedInstance.mainManagedContext

		if let user = (internalContext.safeExecuteFetchRequest(ManagedUser.fetchRequestForHandle(handle)) as? [ManagedUser])?.first {
			return user
		}
		else {
			return ManagedUser(handle: handle, inManagedContext: internalContext)
		}
	}

	class func fetchRequestForHandle(handle: String) -> NSFetchRequest {
		let fetchRequest = NSFetchRequest(entityName: self.entityName())
		fetchRequest.predicate = NSPredicate(format: "%K == %@", "handle", handle)
		return fetchRequest
	}

}
