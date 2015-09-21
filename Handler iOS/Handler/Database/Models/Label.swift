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
		self.id = label.id
		self.name = label.name
		self.type = label.type
	}

}
