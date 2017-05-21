//
//  MessageManager.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 17/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

struct MessageDao {
	
	static func updateOrCreateMessage(messageData : MessageData, context : NSManagedObjectContext = CoreDataStack.shared.viewContext) -> Message {
		
		let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", messageData.identifier!)
		fetchRequest.fetchBatchSize = 1
		
		if let message = context.safeExecute(fetchRequest).first {
			message.setMessageData(messageData)
			return message
		}
		let message = Message(data: messageData, context: context)
		
		if let senderData = messageData.sender {
			message.sender = UserDao.updateOrCreateUser(userData: senderData, context: context)
		}
		
		if let recipientsData = messageData.recipients {
			for recipientData in recipientsData {
				let user  = UserDao.updateOrCreateUser(userData: recipientData, context: context)
				message.addToRecipients(user)
			}
		}
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: AbstractMessageMailboxViewController.mailboxNeedsUpdate, object: nil, userInfo: nil)
		}
		
		return message
	}
	
	
	static var archiveFetchRequest : NSFetchRequest<Message> {
		return messageFetchRequestForFolder(folder: .Archived)
	}
	
	static var sentFetchRequest : NSFetchRequest<Message> {
		return messageFetchRequestForFolder(folder: .Sent)
	}
	
	static var draftsFetchRequest : NSFetchRequest<Message> {
		return messageFetchRequestForFolder(folder: .Draft)
	}
	
	static var flaggedFetchRequest : NSFetchRequest<Message> {
		let predicate = NSPredicate(format: "starred != nil && starred == YES")
		let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
		return fetchRequest
	}
	
	
	static private func messageFetchRequestForFolder(folder : Folder) -> NSFetchRequest<Message> {
		let predicate = NSPredicate(format: "folderString == %@", folder.rawValue)
		let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
		fetchRequest.fetchBatchSize = 20
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
		return fetchRequest
	}
	
	//
	//
	//    static func deleteOldArchivedMessages() {
	//        let managedContext = CoreDataUtility.backgroundContext
	//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
	//        fetchRequest.returnsObjectsAsFaults = false
	//
	//        let limitDate = Date().addingTimeInterval(-60 * 24 * 60 * 60)
	//        fetchRequest.predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@ && createdAt < %@", "INBOX", "SENT", limitDate as CVarArg)
	//
	//        let results = managedContext.safeExecuteFetchRequest(fetchRequest)
	//        for managedObject in results {
	//            managedContext.delete(managedObject)
	//        }
	//    }
	//
	//    // Keeps only the most recent 1000 messages
	//    static func deleteArchivedMessagesAfter1000() {
	//
	//        let managedContext = CoreDataUtility.backgroundContext
	//
	//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
	//        fetchRequest.returnsObjectsAsFaults = false
	//        fetchRequest.predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@", "INBOX", "SENT")
	//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
	//
	//        let messages: [Message] = managedContext.safeExecuteFetchRequest(fetchRequest)
	//
	//        if messages.count > 1000 {
	//            for i in 1000...messages.count - 1 {
	//                let message = messages[i]
	//                managedContext.delete(message)
	//            }
	//        }
	//    }
	//
	//    static var inboxFetchRequest : NSFetchRequest<NSFetchRequestResult> {
	//
	//        let predicate = NSPredicate(format: "SUBQUERY(messages, $t, $t.folderString == %@).@count != 0", Folder.Inbox.rawValue)
	//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Conversation.entityName())
	//        fetchRequest.fetchBatchSize = 20
	//        fetchRequest.predicate = predicate
	//        // OTTODO: It should be sorted by date.
	//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
	//        return fetchRequest
	//
	//    }
	
	static func fetchRequestForConversationWithInboxType(_ type: MailboxType) -> NSFetchRequest<Conversation> {
		
		switch type {
			
		case .Inbox :
			let predicate = NSPredicate(format: "SUBQUERY(messages, $t, $t.folderString == %@).@count != 0", Folder.Inbox.rawValue)
			let fetchRequest : NSFetchRequest<Conversation> = Conversation.fetchRequest()
			fetchRequest.fetchBatchSize = 20
			fetchRequest.predicate = predicate
			// OTTODO: It should be sorted by date.
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
			return fetchRequest
			
		default :
			let predicate = NSPredicate(format: "SUBQUERY(messages, $t, $t.read != nil && $t.read == NO).@count != 0")
			let fetchRequest : NSFetchRequest<Conversation> = Conversation.fetchRequest()
			fetchRequest.predicate = predicate
			fetchRequest.fetchBatchSize = 20
			// OTTODO: It should be sorted by date.
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
			return fetchRequest
		}
		
	}
	
	static func fetchRequestForMessagesWithInboxType(_ type: MailboxType) -> NSFetchRequest<Message> {
		
		switch type {
		case .AllChanges :
			let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
			fetchRequest.fetchBatchSize = 20
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
			return fetchRequest
			
		case .Sent :
			let predicate = NSPredicate(format: "folderString == %@", Folder.Sent.rawValue)
			let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
			fetchRequest.predicate = predicate
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
			return fetchRequest
			
		case .Flagged:
			let predicate = NSPredicate(format: "starred != nil && starred == YES")
			let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
			fetchRequest.predicate = predicate
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
			return fetchRequest
			
		case .Drafts:
			let predicate = NSPredicate(format: "folderString == %@", Folder.Draft.rawValue)
			let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
			fetchRequest.predicate = predicate
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
			return fetchRequest
			
		default :
			if type != .Archive {
				return fetchRequestForMessagesWithLabelWithId(type.rawValue)
			} else {
				// handle archive case
				let predicate = NSPredicate(format: "folderString == %@", Folder.Archived.rawValue)
				let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
				fetchRequest.fetchBatchSize = 20
				fetchRequest.predicate = predicate
				fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
				return fetchRequest
			}
		}
		
	}
	
	static func fetchRequestForMessagesWithLabelWithId(_ id: String) -> NSFetchRequest<Message> {
		let predicate = NSPredicate(format: "ANY labels.id == %@", id)
		let fetchRequest : NSFetchRequest<Message> = Message.fetchRequest()
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
		return fetchRequest
	}
	
}
