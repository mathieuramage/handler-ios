//
//  Attatchment.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import HandlerSDK

final class Attatchment: NSManagedObject, CoreDataConvertible {
	
	typealias HRType = HRAttachment

	required convenience init(hrType: HRType, managedObjectContext: NSManagedObjectContext) {
		self.init(managedObjectContext: managedObjectContext)
		
		updateFromHRType(hrType)
	}
	
	func updateFromHRType(attachment: HRType) {
		self.id = attachment.id
		self.content_type = attachment.content_type
		self.url = attachment.url
		self.filename = attachment.filename
		self.size = attachment.size
		self.upload_complete = attachment.uploadComplete
	}
}
