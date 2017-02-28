//
//  Conversation+CoreDataClass.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 18/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData


extension Conversation {
	
	convenience init(data : ConversationData, context : NSManagedObjectContext) {
		self.init(context: context)
		self.setConversationData(data)
	}
	
	func setConversationData(_ data : ConversationData) {
		
		self.identifier = data.identifier
		
		var latest = Date(timeIntervalSince1970: 0)
		if let messagesData = data.messages {
			for messageData in messagesData {
				let message = MessageDao.updateOrCreateMessage(messageData: messageData, context: self.managedObjectContext!)
				self.addToMessages(message)
				if message.createdAt?.isLaterThanDate(latest) == true {
					latest = message.createdAt as! Date
				}
			}
		}
		self.latestMessageDate = latest as NSDate
	}
	
	var read : Bool {
		if let unread = value(forKey: "unreadMessages") as? NSArray {
			for message in unread {
				print((message as! Message).content)
			}
			return unread.count == 0
		}
		return true
	}
	
	var starred : Bool {
		if let unread = value(forKey: "starredMessages") as? NSArray {
			return unread.count == 0
		}
		return true
	}
	
	var archived : Bool {
		return false
	}
	
	
	var latestMessage : Message? {
		get {
			guard let messages = messages?.allObjects as? [Message], messages.count > 0 else {
				return nil
			}
			return messages.sorted { (m1, m2) -> Bool in
				m1.createdAt!.compare(m2.createdAt! as Date) == .orderedDescending
				}.first
		}
	}
	
	var latestUnreadMessage : Message? {
		get {
			guard let messages = messages?.allObjects as? [Message], messages.count > 0 else {
				return nil
			}
			
			return messages
				.filter({ m -> Bool in
					return !m.read
				})
				.sorted { (m1, m2) -> Bool in
					m1.createdAt!.compare(m2.createdAt! as Date) == .orderedDescending
				}.first
		}
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
	
	var oldestUnreadMessage : Message? {
		let sortedUnreadMessages = orderedMessagesByCreationTime().filter({ (message) -> Bool in
			return message.read
		})
		
		return sortedUnreadMessages.last
	}
}
