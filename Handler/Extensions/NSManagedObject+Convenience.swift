//
//  Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
	
	class func entityName() -> String {
		let classString = NSStringFromClass(self).stringByReplacingOccurrencesOfString("Managed", withString: "")
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
		return NSEntityDescription.entityForName(entityName, inManagedObjectContext: DatabaseManager.sharedInstance.mainManagedContext)
	}
	
	public class func backgroundEntityDescription() -> NSEntityDescription? {
		let entityName = self.entityName()
		return NSEntityDescription.entityForName(entityName, inManagedObjectContext: DatabaseManager.sharedInstance.mainManagedContext)
	}
	
	static func fetchRequestForID(id: String) -> NSFetchRequest? {
		let fetchRequest = NSFetchRequest(entityName: self.entityName())
		fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", id)
		
		return fetchRequest
	}
	
	static func backgroundFetchRequestForID(id: String) -> NSFetchRequest? {
		let fetchRequest = NSFetchRequest(entityName: self.entityName())
		fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", id)
		
		return fetchRequest
	}
}