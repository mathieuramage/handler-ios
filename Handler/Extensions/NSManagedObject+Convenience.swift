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
		let classString = NSStringFromClass(self).replacingOccurrences(of: "Managed", with: "")
		// The entity is the last component of dot-separated class name:
		let components = classString.components(separatedBy: ".")
		return components.last ?? classString
	}
	convenience init(managedObjectContext: NSManagedObjectContext) {
		let entityName = type(of: self).entityName()
		let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)!
		self.init(entity: entity, insertInto: managedObjectContext)
	}
	
	public class func entityDescription() -> NSEntityDescription? {
		let entityName = self.entityName()
		return NSEntityDescription.entity(forEntityName: entityName, in: PersistenceManager.mainManagedContext)
	}
	
	public class func backgroundEntityDescription() -> NSEntityDescription? {
		let entityName = self.entityName()
		return NSEntityDescription.entity(forEntityName: entityName, in: PersistenceManager.mainManagedContext)
	}
	
	static func fetchRequestForID(_ id: String) -> NSFetchRequest<NSFetchRequestResult>? {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
		fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", id)
		
		return fetchRequest
	}
	
	static func backgroundFetchRequestForID(_ id: String) -> NSFetchRequest<NSFetchRequestResult>? {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
		fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", id)
		
		return fetchRequest
	}
}
