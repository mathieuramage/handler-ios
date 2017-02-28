//
//  Message+CoreDataClass.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 18/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


extension Message {
	
	var archived : Bool {
		return folderString == Folder.Archived.rawValue
	}
	
	var folder : Folder? {
		guard let folderString = folderString else { return nil }
		return Folder(rawValue: folderString)
	}
	
	convenience init(data : MessageData, context : NSManagedObjectContext) {
		self.init(context: context)
		setMessageData(data)
	}
	
	func setMessageData(_ data : MessageData) {
		identifier = data.identifier
		subject = data.subject
		content = data.content
		createdAt = data.createdAt?.NSDateValue
		updatedAt = data.updatedAt?.NSDateValue
		read = data.read
		folderString = data.folderString
	}
	
	// MARK: Utility getters
	
	
	var recipientsWithoutSelf : [User]? {
		guard let recipients = recipients?.allObjects as? [User] else { return nil }
		return recipients.filter({ user -> Bool in
			return user.handle != AuthUtility.shared.user?.handle
		})
	}
	
	var isDraft: Bool {
		return folderString == SystemLabels.Drafts.rawValue
	}
	
	var hasReplyPrefix : Bool {
		let replyPrefix = "Re:"
		guard let subject = self.subject else { return false }
		return subject.lowercased().hasPrefix(replyPrefix.lowercased())
		
	}
	
	var hasFowardPrefix : Bool {
		let forwardPrefix = "Fwd:"
		guard let subject = self.subject else {
			return false
		}
		return subject.lowercased().hasPrefix(forwardPrefix.lowercased())
	}
	
	var hasValidSubject : Bool {
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
	
//	func isValidToSend -> Bool {
//		guard let recipients = recipients else { return false }
//		return ((recipients.allObjects.count)! > 0 && hasValidSubject() && hasValidSubject())
//	
//	}
	
	
	// MARK: Fetch Requests
	
	
	//
	//    class func fetchRequestForUploadCompletion() -> NSFetchRequest<NSFetchRequestResult> {
	//        let predicate = NSPredicate(format: "NONE attachments.upload_complete == NO")
	//        let secondPredicate = NSPredicate(format: "shouldBeSent == YES")
	//
	//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName())
	//        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, secondPredicate])
	//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
	//        return fetchRequest
	//    }
	//
	//    class func latestUpdatedMessageDate(inManagedContext context: NSManagedObjectContext) -> Date? {
	//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
	//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
	//        fetchRequest.fetchBatchSize = 1
	//
	//        let results: [Message] = context.safeExecuteFetchRequest(fetchRequest)
	//
	//        if let lastMessageDate = results.first?.updatedAt {
	//            return lastMessageDate as Date
	//        }
	//
	//        return nil
	//    }
	
}


enum Folder : String {
	case Inbox = "inbox"
	case Sent = "sent"
	case Archived = "archived"
	case Deleted = "deleted"
	case Draft = "draft"
}
