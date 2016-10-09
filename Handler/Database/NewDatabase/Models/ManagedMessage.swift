//
//  Message.swift
//
//
//  Created by Otávio on 18/09/16.
//
//

import Foundation
import CoreData
import SwiftyJSON

typealias Message = ManagedMessage

class ManagedMessage: NSManagedObject {



	/*
 _id	ObjectID	Required | Unique
 _user	User	Required
 _sender	User	Required
 conversationId	UUID	Required | Unique | Default: uuid.v4
 subject	String	Required | Default: ""
 message	String	Required | Default: ""
 recipients	[User]	# Can be empty if folder is 'draft'
 isRead	String	Required | Default: false
 folder	String	Required | Default: ‘draft’ | Enum: ['inbox', 'sent', 'archived', 'deleted', 'draft']
 labels	[String]	# Can be empty. Sample: 'job', 'invoices', ...
 isStar	Boolean	# Can be empty.
	*/

	var starred : Bool? {
		if let starredValue = starredValue {
			return starredValue.boolValue
		}
		return false

	}

	var read : Bool {
		if let readValue = readValue {
			return readValue.boolValue
		}

		return false
	}

	//	var user : User
	var folder : Folder {
		get {
			if let folderType = folderType, let folder = Folder(rawValue: folderType) {
				return folder
			}
			else {
				return .Inbox
			}

		}
	}

	var archived : Bool {
		get {
			return folder == .Archived
		}
	}

	private convenience init(json: JSON, inContext context: NSManagedObjectContext) {
		self.init(managedObjectContext: context)

		identifier = json["id"].stringValue
		sender = ManagedUser.userWithJSON(json["sender"], inContext: context)
		conversationId = json["conversationId"].stringValue

		conversation = ManagedConversation.conversationWithID(conversationId!, inContext: context)

		subject = json["subject"].stringValue
		content = json["message"].stringValue

		if let recipientJsons = json["recipients"].array {
			for recipientJson in recipientJsons {
				let recipient = ManagedUser.userWithJSON(recipientJson, inContext: context)

				addRecipientsObject(recipient)
			}
		}

		readValue = json["isRead"].boolValue

		folderType = json["folder"].stringValue

		if let labelJsons = json["labels"].array {
			for labelJson in labelJsons {
				let label = ManagedLabel(id: labelJson.stringValue, inContext: context)

				label.message = self
			}
		}

		starredValue = json["isStar"].bool

		if let createdAtStr = json["createdAt"].string {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			createdAt = formatter.dateFromString(createdAtStr)!
		} else {
			createdAt = NSDate()
		}

		if let updatedAtStr = json["updatedAt"].string {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			updatedAt = formatter.dateFromString(updatedAtStr)!
		} else {
			updatedAt = NSDate()
		}
	}

	class func messageWithJSON(json: JSON, inContext context: NSManagedObjectContext) -> ManagedMessage {

		let identifier = json["id"].stringValue

		let fetchRequest = NSFetchRequest(entityName: self.entityName())
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
		fetchRequest.fetchBatchSize = 1

		if let message = (context.safeExecuteFetchRequest(fetchRequest) as [Message]).first {
			return message
		}

		let message = ManagedMessage(json: json, inContext: context)

		return message
	}

	func moveToArchive() {
		self.removeLabelWithID(SystemLabels.Inbox.rawValue)
	}

	func moveToInbox() {
		self.addLabelWithID(SystemLabels.Inbox.rawValue)
	}

	func flag() {
		self.addLabelWithID(SystemLabels.Flagged.rawValue)
	}

	func unflag() {
		self.removeLabelWithID(SystemLabels.Flagged.rawValue)
	}

	func markAsRead() {
		self.removeLabelWithID(SystemLabels.Unread.rawValue)
	}

	func markAsUnread() {
		self.addLabelWithID(SystemLabels.Unread.rawValue)
	}

	// MARK: Refresh

	func refreshFromAPI() {
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
			return !read
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

	func saveAsDraft() {
		//		self.addLabelWithID("DRAFT")
		//		self.sender = User.me()
	}

	func deleteFromDatabase() {
		let context = self.managedObjectContext

		context?.deleteObject(self)
	}


	// MARK: Fetch Requests

	class func fetchRequestForMessagesWithInboxType(type: MailboxType) -> NSFetchRequest {
		if type == MailboxType.AllChanges {
			let fetchRequest = NSFetchRequest(entityName: ManagedMessage.entityName())
			fetchRequest.fetchBatchSize = 20
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
			return fetchRequest
		} else if type == .Inbox {
			let fetchRequest = NSFetchRequest(entityName: Thread.entityName())
			fetchRequest.fetchBatchSize = 20
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
			return fetchRequest
		} else if type == .Unread {
			let predicate = NSPredicate(format: "SUBQUERY(messages, $t, ANY $t.labels.id == %@).@count != 0", type.rawValue)
			let fetchRequest = NSFetchRequest(entityName: Thread.entityName())
			fetchRequest.predicate = predicate
			fetchRequest.fetchBatchSize = 20
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
			return fetchRequest
		}else if type != .Archive {
			return fetchRequestForMessagesWithLabelWithId(type.rawValue)
		} else {
			// handle archive case
			let predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@", "INBOX", "SENT")
			let fetchRequest = NSFetchRequest(entityName: entityName())
			fetchRequest.fetchBatchSize = 20
			fetchRequest.predicate = predicate
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
			return fetchRequest
		}
	}

	class func fetchRequestForMessagesWithLabelWithId(id: String) -> NSFetchRequest {
		let predicate = NSPredicate(format: "ANY labels.id == %@", id)
		let fetchRequest = NSFetchRequest(entityName: entityName())
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
		return fetchRequest
	}

	class func fetchRequestForUploadCompletion() -> NSFetchRequest {
		let predicate = NSPredicate(format: "NONE attachments.upload_complete == NO")
		let secondPredicate = NSPredicate(format: "shouldBeSent == YES")

		let fetchRequest = NSFetchRequest(entityName: entityName())
		fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, secondPredicate])
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
		return fetchRequest
	}

	class func latestUpdatedMessageDate(inManagedContext context: NSManagedObjectContext) -> NSDate? {
		let fetchRequest = NSFetchRequest(entityName: self.entityName())
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
		fetchRequest.fetchBatchSize = 1

		let results: [Message] = context.safeExecuteFetchRequest(fetchRequest)

		if let lastMessageDate = results.first?.updatedAt {
			return lastMessageDate
		}

		return nil
	}
}

enum Folder : String {
	case Inbox = "inbox"
	case Sent = "sent"
	case Archived = "archived"
	case Deleted = "deleted"
	case Draft = "draft"
}
