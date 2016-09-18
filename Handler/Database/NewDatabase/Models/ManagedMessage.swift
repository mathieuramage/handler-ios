//
//  Message.swift
//  
//
//  Created by Otávio on 18/09/16.
//
//

import Foundation
import CoreData

class ManagedMessage: NSManagedObject {

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

	// MARK: Refresh

	func refreshFromAPI(){
		//		if let id = self.id {
		//			APICommunicator.sharedInstance.getMessageWithCallback(id) { (message, error) -> Void in
		//				guard let message = message else {
		//					if let error = error {
		//						ErrorHandler.performErrorActions(error)
		//					}
		//					return
		//				}
		//				self.updateFromHRType(message)
		//			}
		//		}
	}

	// MARK: Labels

	func updateLabelsOnHRAPI(completion: ((success: Bool)->Void)? = nil){
		//		if let id = self.id {
		//			APICommunicator.sharedInstance.setLabelsToMessageWithID(id, setLabels: hrTypeLabels(), callback: { (labels, error) -> Void in
		//				guard let labels = labels else {
		//					if let error = error {
		//						ErrorHandler.performErrorActions(error)
		//					}
		//					completion?(success: false)
		//					return
		//				}
		//
		//				self.setLabelsFromHRTypes(labels)
		//				MailDatabaseManager.sharedInstance.saveBackgroundContext()
		//				completion?(success: true)
		//			})
		//		}
	}

	private func addLabelWithID(id: String, updateOnApi: Bool = true){
		//		if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
		//			if let label = Label.fromID(id) {
		//				if let myLabels = backgroundSelf.labels {
		//					let newSet = myLabels.setByAddingObject(label)
		//					backgroundSelf.labels = newSet
		//				}
		//
		//				if updateOnApi {
		//					backgroundSelf.updateLabelsOnHRAPI()
		//				}
		//				backgroundSelf.thread?.updateInbox()
		//				MailDatabaseManager.sharedInstance.saveBackgroundContext()
		//			}
		//		}
	}

	private func removeLabelWithID(id: String, updateOnApi: Bool = true){
		//		if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
		//			if let labelsArray = backgroundSelf.labels?.allObjects {
		//				for label in labelsArray {
		//					if label.id == id {
		//						if let myLabels = backgroundSelf.labels {
		//							let newSet = NSMutableSet(set: myLabels)
		//							newSet.removeObject(label)
		//							backgroundSelf.labels = NSSet(set: newSet)
		//						}
		//
		//						if updateOnApi {
		//							backgroundSelf.updateLabelsOnHRAPI()
		//						}
		//						backgroundSelf.thread?.updateInbox()
		//						MailDatabaseManager.sharedInstance.saveBackgroundContext()
		//						return
		//					}
		//				}
		//			}
		//		}
	}

	// OTTODO: Implement?
	func setLabelsFromHRTypes(labels: [AnyObject]) {

	}

	// OTTODO: Implement?
	func hrTypeLabels() -> [AnyObject] {
		return []
	}

	// OTTODO: Implement?
	func hrTypeRecipients() -> [AnyObject] {
		return []
	}

	// MARK: Utility getters

	func recipientsWithoutSelf() -> NSSet? {
		if let recipients = self.recipients?.allObjects as? [ManagedUser] {
			for recipient in recipients {
				if recipient.handle == ManagedUser.me()?.handle {
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
			//			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
			//				if let labels = backgroundSelf.labels {
			//					for label in labels {
			//						if label.id == "UNREAD" {
			//							unread = true
			//						}
			//					}
			//				}
			//			}
			return unread
		}
	}

	var isInbox: Bool {
		get {
			var unread = false
			//			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
			//				if let labels = backgroundSelf.labels {
			//					for label in labels {
			//						if label.id == "INBOX" {
			//							unread = true
			//						}
			//					}
			//				}
			//			}
			return unread
		}
	}

	var isFlagged: Bool {
		get {
			//			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
			//
			//				if let labels = backgroundSelf.labels {
			//					for label in labels {
			//						if label.id == "IMPORTANT" {
			//							return true
			//						}
			//					}
			//				}
			//			}
			return false
		}
	}

	var isArchived: Bool {
		get {
			//			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
			//
			//				if let labels = backgroundSelf.labels {
			//					for label in labels {
			//						if label.id == "INBOX" {
			//							return false
			//						}
			//					}
			//				}
			//			}
			return true
		}
	}

	var isDraft: Bool {
		get {
			//			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
			//
			//				if let labels = backgroundSelf.labels {
			//					for label in labels {
			//						if label.id == "DRAFT" {
			//							return true
			//						}
			//					}
			//				}
			//			}
			return false
		}
	}

	// TODO: Make it locale indepent
	let replyPrefix = "Re:"
	let forwardPrefix = "Fwd:"

	func hasReplyPrefix() -> Bool {
		//		guard let subject = self.subject else {
		//			return false
		//		}
		//
		//		return subject.lowercaseString.hasPrefix(replyPrefix.lowercaseString)

		return false
	}

	func hasFowardPrefix() -> Bool {
		//		guard let subject = self.subject else {
		//			return false
		//		}
		//
		//		return subject.lowercaseString.hasPrefix(forwardPrefix.lowercaseString)

		return false

	}

	func hasValidSubject() -> Bool {
		//		guard let subject = self.subject else {
		//			return false
		//		}
		//
		//		return !subject.isEmpty

		return false
	}

	func hasValidContent() -> Bool {
		//		guard let content = self.content else {
		//			return false
		//		}
		//
		//		return !content.isEmpty

		return false

	}

	func isValidToSend() -> Bool {
		//		return (recipients?.count > 0 && hasValidSubject() && hasValidSubject())

		return false
	}

	// MARK: Drafts

	func saveAsDraft(){
		//		self.addLabelWithID("DRAFT")
		//		self.sender = User.me()
	}

	func deleteFromDatabase(){
		let context = self.managedObjectContext

		context?.deleteObject(self)
	}


	// MARK: Fetch Requests

	class func fetchRequestForMessagesWithInboxType(type: MailboxType) -> NSFetchRequest {
		if type == MailboxType.AllChanges {
			let fetchRequest = NSFetchRequest(entityName: ManagedMessage.entityName())
			fetchRequest.fetchBatchSize = 20
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent_at", ascending: false)]
			return fetchRequest
		} else if type == .Inbox {
			let predicate = NSPredicate(format: "showInInbox == YES")
			let fetchRequest = NSFetchRequest(entityName: Thread.entityName())
			fetchRequest.predicate = predicate
			fetchRequest.fetchBatchSize = 20
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_message_date", ascending: false)]
			return fetchRequest
		} else if type == .Unread {
			let predicate = NSPredicate(format: "SUBQUERY(messages, $t, ANY $t.labels.id == %@).@count != 0", type.rawValue)
			let fetchRequest = NSFetchRequest(entityName: Thread.entityName())
			fetchRequest.predicate = predicate
			fetchRequest.fetchBatchSize = 20
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_message_date", ascending: false)]
			return fetchRequest
		}else if type != .Archive {
			return fetchRequestForMessagesWithLabelWithId(type.rawValue)
		}else{
			// handle archive case
			let predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@", "INBOX", "SENT")
			let fetchRequest = NSFetchRequest(entityName: entityName())
			fetchRequest.fetchBatchSize = 20
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
	
	class func fetchRequestForUploadCompletion() -> NSFetchRequest {
		let predicate = NSPredicate(format: "NONE attachments.upload_complete == NO")
		let secondPredicate = NSPredicate(format: "shouldBeSent == YES")
		
		let fetchRequest = NSFetchRequest(entityName: entityName())
		fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, secondPredicate])
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent_at", ascending: false)]
		return fetchRequest
	}


}
