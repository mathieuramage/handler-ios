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
		
		updateFromHRType(message)
		
		message.fetchLabels { (labels, error) -> Void in
			guard let labels = labels else {
				print(error)

				return
			}
			
			self.setLabelsFromHRTypes(labels)
		}
	}
	
	func updateFromHRType(message: HRType) {
		self.content = message.content
		self.id = message.id
		self.sent_at = NSDate.fromString(message.sent_at)
		self.subject = message.subject
		self.sender = User.fromHRType(message.sender!)
		if message.thread != "" {
			self.thread = Thread.fromID(message.thread)
			if let sentAt = self.sent_at {
				if let threadDate = self.thread?.last_message_date {
					self.thread?.last_message_date = threadDate.laterDate(sentAt)
				}else{
					self.thread?.last_message_date = sentAt
				}
			}
		}
		
		if let id = self.id {
			APICommunicator.sharedInstance.fetchLabelsForMessageWithID(id, callback: { (labels, error) -> Void in
				guard let labels = labels else {
					print(error)
					
					return
				}
				
				self.setLabelsFromHRTypes(labels)
			})
		}
		
		if let recipients = message.recipients {
			let recipientsSet = NSMutableSet()
			for recipient in recipients {
				if let cdRecipient = User.fromHRType(recipient) {
					recipientsSet.addObject(cdRecipient)
				}
			}
			self.recipients = recipientsSet
		}
	}
	
	// MARK: Mailboxes
	
	func moveToArchive(){
		self.removeLabelWithID(SystemLabels.Inbox.rawValue)
	}

	func moveToInbox(){
		self.addLabelWithID(SystemLabels.Inbox.rawValue)
	}

	func flag(){
		self.addLabelWithID(SystemLabels.Flagged.rawValue)
	}

	func unflag(){
		self.removeLabelWithID(SystemLabels.Flagged.rawValue)
	}
	
	func markAsRead(){
		self.removeLabelWithID(SystemLabels.Unread.rawValue)
	}
	
	func markAsUnread(){
		self.addLabelWithID(SystemLabels.Unread.rawValue)
	}
	
	// MARK: Labels
	
	func updateLabelsOnHRAPI(){
		if let id = self.id {
			APICommunicator.sharedInstance.setLabelsToMessageWithID(id, setLabels: hrTypeLabels(), callback: { (labels, error) -> Void in
				guard let labels = labels else {
									print(error)

					return
				}
				
				self.setLabelsFromHRTypes(labels)
			})
		}
	}
	
	private func addLabelWithID(id: String, updateOnApi: Bool = true){
		if let label = Label.fromID(id) {
			self.labels = self.labels?.setByAddingObject(label)
			if updateOnApi {
				updateLabelsOnHRAPI()
			}
		}
	}
	
	private func removeLabelWithID(id: String, updateOnApi: Bool = true){
		if let labelsArray = self.labels?.allObjects {
			let newLabels = NSMutableSet(set: self.labels!)
			for label in labelsArray {
				if label.id == id {
					newLabels.removeObject(label)
					self.labels = newLabels
					if updateOnApi {
						updateLabelsOnHRAPI()
					}
					return
				}
			}
		}
	}
	
	func setLabelsFromHRTypes(labels: [HRLabel]){
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
	
	func hrTypeLabels() -> [HRLabel] {
		var hrLabels = [HRLabel]()
		if let labels = self.labels {
			for label in labels {
				let hrLabel = HRLabel()
				hrLabel.id = label.id
				hrLabel.name = label.name
				hrLabel.type = label.type
				hrLabels.append(hrLabel)
			}
		}
		return hrLabels
	}
	
	// MARK: Utility getters
	
	func recipientsWithoutSelf()->NSSet? {
		if let recipients = self.recipients?.allObjects as? [User] {
			for recipient in recipients {
				if recipient.handle == HRUserSessionManager.sharedManager.currentUser?.handle {
					let mutableSet = NSMutableSet(set: self.recipients!)
					mutableSet.removeObject(recipient)
					return NSSet(set: mutableSet)
 				}
			}
		}
		
		return self.recipients
	}
	
	// MARK: State getter utilities

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

	// MARK: Fetch Requests
	
	class func fetchRequestForMessagesWithInboxType(type: MailboxType) -> NSFetchRequest {
		if type == .Inbox {
			//let secondPredicate = NSPredicate(format: "SUBQUERY(messages, $t, NONE $t.labels.id == %@).@count == 0", "SENT")
			let predicate = NSPredicate(format: "SUBQUERY(messages, $t, ANY $t.labels.id == %@).@count != 0", "INBOX")
			let fetchRequest = NSFetchRequest(entityName: Thread.entityName())
			//fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [secondPredicate, predicate])
			fetchRequest.predicate = predicate
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_message_date", ascending: false)]
			return fetchRequest
		}else if type != .Archive {
			return fetchRequestForMessagesWithLabelWithId(type.rawValue)
		}else{
			// handle archive case
			let predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@", "INBOX", "SENT")
			let fetchRequest = NSFetchRequest(entityName: entityName())
			fetchRequest.predicate = predicate
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent_at", ascending: false)]
			return fetchRequest
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
