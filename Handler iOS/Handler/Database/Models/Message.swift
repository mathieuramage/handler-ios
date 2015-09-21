//
//  Message.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import HandlerSDK

final class Message: NSManagedObject, CoreDataConvertible {
	
	typealias HRType = HRMessage
	
	required convenience init(hrType message: HRType, managedObjectContext: NSManagedObjectContext){
		self.init(managedObjectContext: managedObjectContext)
		self.content = message.content
		self.id = message.id
		print(message.sent_at)
		self.sent_at = NSDate.fromString(message.sent_at)
		self.subject = message.subject
		self.sender = User.fromHRType(message.sender!)
	}
}
