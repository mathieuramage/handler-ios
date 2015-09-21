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
	
	public class func entityName() -> String {
		return NSStringFromClass(self)
	}
	
	convenience init(managedObjectContext: NSManagedObjectContext) {
		let entityName = self.dynamicType.entityName()
		let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)!
		self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
	}
}