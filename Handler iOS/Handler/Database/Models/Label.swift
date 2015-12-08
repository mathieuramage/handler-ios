//
//  Label.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import HandlerSDK

final class Label: NSManagedObject, CoreDataConvertible {
	
	typealias HRType = HRLabel
	
	required convenience init(hrType label: HRLabel, managedObjectContext: NSManagedObjectContext){
		self.init(managedObjectContext: managedObjectContext)
        DatabaseChangesCache.sharedInstance.waitingForInit = false

		self.updateFromHRType(label)
	}
	
	convenience init(id: String, managedObjectContext: NSManagedObjectContext){
		self.init(managedObjectContext: managedObjectContext)
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "id", value: id))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "name", value: ""))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "type", value: ""))
        DatabaseChangesCache.sharedInstance.executeChangesForObjectID(self.objectID)
	}
	
	func updateFromHRType(label: HRType) {
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "id", value: label.id))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "name", value: label.name))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "type", value: label.type))
        DatabaseChangesCache.sharedInstance.executeChangesForObjectID(self.objectID)
	}
	
	func toHRType() -> HRLabel {
		let hrLabel = HRLabel()
		hrLabel.id = self.id ?? ""
		hrLabel.name = self.name ?? ""
		hrLabel.type = self.type ?? ""
		return hrLabel
	}
}
