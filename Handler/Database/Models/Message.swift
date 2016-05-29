//
//  Message.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData
import HandleriOSSDK

final class Message: NSManagedObject, CoreDataConvertible {

	typealias HRType = HRMessage

	required convenience init(hrType message: HRType, managedObjectContext: NSManagedObjectContext){
		self.init(managedObjectContext: managedObjectContext)

		updateFromHRType(message)
	}

	func updateFromHRType(message: HRType) {
		self.shouldBeSent = NSNumber(bool: false)
		self.content = message.content
		self.id = message.id
		self.sent_at = NSDate.fromString(message.sent_at)
		self.subject = message.subject
		self.sender = User.fromHRType(message.sender!)

		if message.thread != "" {
			self.thread = Thread.fromID(message.thread, inContext: self.managedObjectContext)

			if let sentAt = self.sent_at {
				if let threadDate = self.thread?.last_message_date {
					self.thread?.last_message_date = threadDate.laterDate(sentAt)

				}else{
					self.thread?.last_message_date = sentAt

				}
			}
			self.thread?.updateInbox()
		}

		if let id = self.id {
			APICommunicator.sharedInstance.fetchLabelsForMessageWithID(id, callback: { (labels, error) -> Void in
				guard let labels = labels else {
					if let error = error {
						ErrorHandler.performErrorActions(error)
					}
					return
				}

				self.setLabelsFromHRTypes(labels)
				self.thread?.updateInbox()
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

		if let attachments = message.attachments {
			let attachmentsSet = NSMutableSet()
			for attachment in attachments {
				if let cdAttachment = Attachment.fromHRType(attachment) {
					attachmentsSet.addObject(cdAttachment)
				}
			}
			self.attachments = attachmentsSet
		}

		MailDatabaseManager.sharedInstance.saveBackgroundContext()
	}

	func toHRType() -> HRMessage {
		let hrMessage = HRMessage()
		hrMessage.content = self.content ?? ""
		hrMessage.id = self.id ?? ""
		hrMessage.sent_at = NSDate.toString(self.sent_at) ?? ""
		hrMessage.subject = self.subject ?? ""
		hrMessage.sender = self.sender?.toHRType()
		hrMessage.thread = self.thread?.id ?? ""
		hrMessage.labels = self.hrTypeLabels()
		hrMessage.recipients = self.hrTypeRecipients()
		hrMessage.attachments = self.hrTypeAttachments()

		return hrMessage
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

	// MARK: Refresh

	func refreshFromAPI(){
		if let id = self.id {
			APICommunicator.sharedInstance.getMessageWithCallback(id) { (message, error) -> Void in
				guard let message = message else {
					if let error = error {
						ErrorHandler.performErrorActions(error)
					}
					return
				}
				self.updateFromHRType(message)
			}
		}
	}

	// MARK: Labels

	func updateLabelsOnHRAPI(completion: ((success: Bool)->Void)? = nil){
		if let id = self.id {
			APICommunicator.sharedInstance.setLabelsToMessageWithID(id, setLabels: hrTypeLabels(), callback: { (labels, error) -> Void in
				guard let labels = labels else {
					if let error = error {
						ErrorHandler.performErrorActions(error)
					}
					completion?(success: false)
					return
				}

				self.setLabelsFromHRTypes(labels)
				MailDatabaseManager.sharedInstance.saveBackgroundContext()
				completion?(success: true)
			})
		}
	}

	private func addLabelWithID(id: String, updateOnApi: Bool = true){
		if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
			if let label = Label.fromID(id) {
				if let myLabels = backgroundSelf.labels {
					let newSet = myLabels.setByAddingObject(label)
					backgroundSelf.labels = newSet
				}

				if updateOnApi {
					backgroundSelf.updateLabelsOnHRAPI()
				}
				backgroundSelf.thread?.updateInbox()
				MailDatabaseManager.sharedInstance.saveBackgroundContext()
			}
		}
	}

	private func removeLabelWithID(id: String, updateOnApi: Bool = true){
		if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
			if let labelsArray = backgroundSelf.labels?.allObjects {
				for label in labelsArray {
					if label.id == id {
						if let myLabels = backgroundSelf.labels {
							let newSet = NSMutableSet(set: myLabels)
							newSet.removeObject(label)
							backgroundSelf.labels = NSSet(set: newSet)
						}

						if updateOnApi {
							backgroundSelf.updateLabelsOnHRAPI()
						}
						backgroundSelf.thread?.updateInbox()
						MailDatabaseManager.sharedInstance.saveBackgroundContext()
						return
					}
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
		if let bgSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext){
			bgSelf.labels = labelsSet

			MailDatabaseManager.sharedInstance.saveBackgroundContext()
			bgSelf.thread?.updateInbox()
		}
	}

	func hrTypeLabels() -> [HRLabel] {
		var hrLabels = [HRLabel]()
		if let labels = self.labels {
			for label in labels {
				let hrLabel = (label as! Label).toHRType()
				hrLabels.append(hrLabel)
			}
		}
		return hrLabels
	}

	func hrTypeRecipients() -> [HRUser] {
		var hrUsers = [HRUser]()
		if let users = self.recipients {
			for user in users {
				let user = (user as! User).toHRType()
				hrUsers.append(user)
			}
		}
		return hrUsers
	}

	func hrTypeAttachments() -> [HRAttachment] {
		var hrAttachments = [HRAttachment]()
		if let attachments = self.attachments {
			for attachment in attachments {
				let hrAttachment = (attachment as! Attachment).toHRType()
				hrAttachments.append(hrAttachment)
			}
		}
		return hrAttachments
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
			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
				if let labels = backgroundSelf.labels {
					for label in labels {
						if label.id == "UNREAD" {
							unread = true
						}
					}
				}
			}
			return unread
		}
	}

	var isInbox: Bool {
		get {
			var unread = false
			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
				if let labels = backgroundSelf.labels {
					for label in labels {
						if label.id == "INBOX" {
							unread = true
						}
					}
				}
			}
			return unread
		}
	}

	var isFlagged: Bool {
		get {
			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {

				if let labels = backgroundSelf.labels {
					for label in labels {
						if label.id == "IMPORTANT" {
							return true
						}
					}
				}
			}
			return false
		}
	}

	var isArchived: Bool {
		get {
			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {

				if let labels = backgroundSelf.labels {
					for label in labels {
						if label.id == "INBOX" {
							return false
						}
					}
				}
			}
			return true
		}
	}

	var isDraft: Bool {
		get {
			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {

				if let labels = backgroundSelf.labels {
					for label in labels {
						if label.id == "DRAFT" {
							return true
						}
					}
				}
			}
			return false
		}
	}

	// TODO: Make it locale indepent
	let replyPrefix = "Re:"
	let forwardPrefix = "Fwd:"

	func hasReplyPrefix() -> Bool {
		guard let subject = self.subject else {
			return false
		}

		return subject.lowercaseString.hasPrefix(replyPrefix.lowercaseString)
	}

	func hasFowardPrefix() -> Bool {
		guard let subject = self.subject else {
			return false
		}

		return subject.lowercaseString.hasPrefix(forwardPrefix.lowercaseString)
	}

	func hasValidSubject() -> Bool {
		guard let subject = self.subject else {
			return false
		}

		return !subject.isEmpty
	}

	func hasValidContent() -> Bool {
		guard let content = self.content else {
			return false
		}

		return !content.isEmpty
	}

	func isValidToSend() -> Bool {
		return (recipients?.count > 0 && hasValidSubject() && hasValidSubject())
	}

	// MARK: Drafts

	func saveAsDraft(){
		self.addLabelWithID("DRAFT")
		self.sender = User.me()
	}

	func deleteFromDatabase(){
		let context = self.managedObjectContext

		context?.deleteObject(self)
	}


	// MARK: Fetch Requests

	class func fetchRequestForMessagesWithInboxType(type: MailboxType) -> NSFetchRequest {
		if type == MailboxType.AllChanges {
			let fetchRequest = NSFetchRequest(entityName: Message.entityName())
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