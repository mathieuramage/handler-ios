//
//  ManagedLabel.swift
//  
//
//  Created by Otávio on 02/10/16.
//
//

import Foundation
import CoreData

class ManagedLabel: NSManagedObject {

	convenience init(id: String, inContext context: NSManagedObjectContext) {
		self.init(managedObjectContext: context)
		self.id = id as NSString?
	}
}
