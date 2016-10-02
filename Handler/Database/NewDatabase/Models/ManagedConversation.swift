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

	class func conversationWithID(identifier: String, inContext context: NSManagedObjectContext) -> ManagedConversation {
		let fetchRequest = NSFetchRequest(entityName: "Conversation")
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
		fetchRequest.fetchBatchSize = 1

		if let conversation = context.safeExecuteFetchRequest(fetchRequest).first as? ManagedConversation {
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
				if message.createdAt!.compare(latest.createdAt!) == .OrderedDescending {
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

				if message.createdAt!.compare(latest!.createdAt!) == .OrderedDescending {
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

	// OTTODO: Review the need of this function and its implementation
	func orderedMessages() -> [Message] {
		guard let messages = messages?.allObjects as? [Message] else {
			return []
		}

		return messages
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

	func updateInbox(){
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
			let sorted =  messageList?.sort({
				if let firstSent = $0.sent_at, let secondSent = $1.sent_at {
					return firstSent.compare(secondSent) == NSComparisonResult.OrderedDescending
				}
				return true
			})
			return sorted?.first
		}
		return nil
	}

	var oldestUnreadMessage : ManagedMessage? {
		var oldestUnread : ManagedMessage? = nil
		//		if let messages = messages {
		//			for message in messages {
		//				let m = message as! LegacyMessage
		//				if m.isUnread {
		//					if oldestUnread == nil {
		//						oldestUnread = m
		//					} else if oldestUnread!.sent_at!.compare(m.sent_at!) == .OrderedAscending {
		//						oldestUnread = m
		//					}
		//				}
		//			}
		//		}
		return oldestUnread
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
			//			message.markAsRead()
		}
	}

	func markAsUnread(message: ManagedMessage) {
		guard let messages = messages?.allObjects as? [ManagedMessage], let currentMessageDate = message.sent_at else {
			return
		}

		for messageToCompare in messages {
			//			guard let messageToCompareDate = messageToCompare.sent_at else {
			//				continue
			//			}

			//			if messageToCompareDate.isLaterThanDate(currentMessageDate) || messageToCompareDate.isEqualToDate(currentMessageDate) {
			//				messageToCompare.markAsUnread()
			//			}
		}
	}
}
