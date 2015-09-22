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
		self.sent_at = NSDate.fromString(message.sent_at)
		self.subject = message.subject
		self.sender = User.fromHRType(message.sender!)

		if let recipients = message.recipients {
			let recipientsSet = NSMutableSet()
			for recipient in recipients {
				if let cdRecipient = User.fromHRType(recipient) {
					recipientsSet.addObject(cdRecipient)
				}
			}
			self.recipients = recipientsSet
		}
		
		message.fetchLabels { (labels, error) -> Void in
			guard let labels = labels else {
				print(error)
				return
			}
			
			let labelsSet = NSMutableSet()
			for label in labels {
				if let cdLabel = Label.fromHRType(label) {
					labelsSet.addObject(cdLabel)
				}
			}
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.labels = labelsSet
				MailDatabaseManager.sharedInstance.saveContext()
			})
		}
	}
	
	var isUnread: Bool {
		get {
			var unread = false
			if let labels = self.labels {
				for label in labels {
					if label.id == "UNREAD" {
						unread = true
					}
				}
			}
			return unread
		}
	}
	
	class func fetchRequestForMessagesWithLabelWithId(id: String) -> NSFetchRequest {
		let predicate = NSPredicate(format: "ANY labels.id == %@", id)
		let fetchRequest = NSFetchRequest(entityName: entityName())
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent_at", ascending: false)]
		return fetchRequest
	}
}
