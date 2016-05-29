//
//  Label.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData
import HandleriOSSDK

final class Label: NSManagedObject, CoreDataConvertible {
	
	typealias HRType = HRLabel
	
	required convenience init(hrType label: HRLabel, managedObjectContext: NSManagedObjectContext){
		self.init(managedObjectContext: managedObjectContext)
		self.updateFromHRType(label)
	}
	
	convenience init(id: String, managedObjectContext: NSManagedObjectContext){
		self.init(managedObjectContext: managedObjectContext)
		self.id = id
		self.name = ""
		self.type = ""
	}
	
	func updateFromHRType(label: HRType) {
		self.id = label.id
		self.name = label.name
		self.type = label.type
	}
	
	func toHRType() -> HRLabel {
		let hrLabel = HRLabel()
		hrLabel.id = self.id ?? ""
		hrLabel.name = self.name ?? ""
		hrLabel.type = self.type ?? ""
		return hrLabel
	}
}
