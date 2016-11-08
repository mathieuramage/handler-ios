//
//  Conversation.swift
//  
//
//  Created by Otávio on 18/09/16.
//
//

import Foundation
import CoreData

typealias Conversation = ManagedConversation
typealias Thread = ManagedConversation

class ManagedConversation: NSManagedObject {

	class func conversationWithID(_ identifier: String, inContext context: NSManagedObjectContext) -> ManagedConversation {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
		fetchRequest.fetchBatchSize = 1

		if let conversation = (context.safeExecuteFetchRequest(fetchRequest) as [Conversation]).first {
			return conversation
		}

		let conversation = ManagedConversation(managedObjectContext: context)
		conversation.identifier = identifier

		return conversation
	}

	var latestMessage : Message? { //this may be unnecessary
		get {
			guard let messages = messages?.allObjects as? [Message], var latest = messages.first else {
				return nil
			}

			for message in messages {
				if message.createdAt!.compare(latest.createdAt! as Date) == .orderedDescending {
					latest = message
				}
			}
			return latest
		}
	}

	var latestUnreadMessage : Message? {
		get {
			guard let messages = messages?.allObjects as? [Message] else {
				return nil
			}

			var latest : Message?

			for message in messages {

				if message.read {
					continue
				}

				if latest == nil {
					latest = message
					continue
				}

				if message.createdAt!.compare(latest!.createdAt! as Date) == .orderedDescending {
					latest = message
				}
			}
			return latest
		}
	}

	func folder() -> Folder? {
		return nil
	}

	func labels() -> [String]? {
		return nil
	}

	func orderedMessagesByCreationTime() -> [Message] {
		guard let messages = messages?.allObjects as? [Message] else {
			return []
		}

		return messages.sorted(by: { (message1, message2) -> Bool in
			guard let date1 = message1.createdAt, let date2 = message2.createdAt else {
				return false
			}

			return date1.isLaterThanDate(date2 as Date)
		})
	}

	func orderedMessagesByUpdateTime() -> [Message] {
		guard let messages = messages?.allObjects as? [Message] else {
			return []
		}

		return messages.sorted(by: { (message1, message2) -> Bool in
			guard let date1 = message1.updatedAt, let date2 = message2.updatedAt else {
				return false
			}

			return date1.isLaterThanDate(date2 as Date)
		})
	}

//	class func fromID(id: String, inContext: NSManagedObjectContext?) -> Thread? {
//		var thread: Thread?
//		let context = inContext ?? DatabaseManager.sharedInstance.backgroundContext
//		if let request = self.fetchRequestForID(id){
//			do {
//				if let threads = try context.executeFetchRequest(request) as? [Thread], let foundthread = threads.first {
//					thread = foundthread
//				}
//			} catch {
//				print(error)
//			}
//		}
//
//		if let thread = thread {
//			return thread
//		}else {
//			let createdthread = Thread(managedObjectContext: context ?? DatabaseManager.sharedInstance.backgroundContext)
//			createdthread.id = id
//			return createdthread
//		}
//	}

	func updateInbox() {
//		var show = false
//		if let messages = self.messages {
//			for message in messages.allObjects as! [ManagedMessage] {
//				if message.isInbox {
//					show = true
//				}
//			}
//		}
//		DatabaseManager.sharedInstance.backgroundContext.saveRecursively()
	}

	var mostRecentMessage: ManagedMessage? {
		if let messages = messages {
			let msgSet = NSSet(set: messages)
			let messageList = msgSet.allObjects as? [ManagedMessage]
			let sorted =  messageList?.sorted(by: {
				if let firstSent = $0.updatedAt, let secondSent = $1.updatedAt {
					return firstSent.compare(secondSent as Date) == ComparisonResult.orderedDescending
				}

				return true
			})
			return sorted?.first
		}

		return nil
	}

	var oldestUnreadMessage : ManagedMessage? {
		let sortedUnreadMessages = orderedMessagesByCreationTime().filter({ (message) -> Bool in
			return message.read
		})

		return sortedUnreadMessages.last
	}

	func archive() {
		if let messages = self.messages {
			for message in messages {
				if let m = message as? ManagedMessage {
					m.moveToArchive()
				}
			}
		}
	}

	func unarchive() {
		if let messages = self.messages {
			for message in messages {
				if let m = message as? ManagedMessage {
					m.moveToInbox()
				}
			}
		}
	}

	func markAsRead() {
		guard let messages = messages?.allObjects as? [ManagedMessage] else {
			return
		}

		for message in messages {
			message.markAsRead()
		}
	}

	func markAsUnread(_ message: ManagedMessage) {
		guard let messages = messages?.allObjects as? [ManagedMessage], let currentMessageDate = message.updatedAt else {
			return
		}

		for messageToCompare in messages {
			guard let messageToCompareDate = messageToCompare.updatedAt else {
				continue
			}

			if messageToCompareDate.isLaterThanDate(currentMessageDate as Date) || (messageToCompareDate == currentMessageDate) {
				messageToCompare.markAsUnread()
			}
		}
	}
}
