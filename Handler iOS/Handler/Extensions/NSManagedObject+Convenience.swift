//
//  Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
	
	class func entityName() -> String {
		let classString = NSStringFromClass(self)
		// The entity is the last component of dot-separated class name:
		let components = classString.componentsSeparatedByString(".")
		return components.last ?? classString
	}
	convenience init(managedObjectContext: NSManagedObjectContext) {
		let entityName = self.dynamicType.entityName()
		let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)!
		self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
	}
	
	public class func entityDescription() -> NSEntityDescription? {
		let entityName = self.entityName()
		return NSEntityDescription.entityForName(entityName, inManagedObjectContext: NSManagedObject.globalManagedObjectContext())
	}
	
	static func fetchRequestForID(id: String) -> NSFetchRequest? {
		guard let entityDescription = self.entityDescription() else{
			print("No entity descrtiption could be created for: \(self.entityName())")
			return nil
		}
		
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = entityDescription
		fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", id)
		
		return fetchRequest
	}
	
	class func globalManagedObjectContext() -> NSManagedObjectContext {
		return MailDatabaseManager.sharedInstance.managedObjectContext
	}
}