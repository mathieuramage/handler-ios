//
//  Thread.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData

class Thread: NSManagedObject {
	
	class func fromID(id: String, inContext: NSManagedObjectContext?) -> Thread? {
		var thread: Thread?
		let context = inContext ?? MailDatabaseManager.sharedInstance.backgroundContext
		if let request = self.fetchRequestForID(id){
			do {
				if let threads = try context.executeFetchRequest(request) as? [Thread], let foundthread = threads.first {
					thread = foundthread
				}
			} catch {
				print(error)
			}
		}
		
		if let thread = thread {
			return thread
		}else {
			let createdthread = Thread(managedObjectContext: context ?? MailDatabaseManager.sharedInstance.backgroundContext)
			createdthread.id = id
			return createdthread
		}
	}
	
	func updateInbox(){
		var show = false
		if let messages = self.messages {
			for message in messages.allObjects as! [Message] {
				if message.isInbox {
					show = true
				}
			}
		}
		self.showInInbox = NSNumber(bool: show)
		MailDatabaseManager.sharedInstance.saveBackgroundContext()
	}
	
	var mostRecentMessage: Message? {
		if let messages = messages {
			let msgSet = NSSet(set: messages)
			let messageList = msgSet.allObjects as? [Message]
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
	
	var oldestUnreadMessage : Message? {
		var oldestUnread : Message? = nil
		if let messages = messages {
			for message in messages {
				let m = message as! Message
				if m.isUnread {
					if oldestUnread == nil {
						oldestUnread = m
					} else if oldestUnread!.sent_at!.compare(m.sent_at!) == .OrderedAscending {
						oldestUnread = m
					}
				}
			}
		}
		return oldestUnread
	}
	
	func archive() {
		if let messages = self.messages {
			for message in messages {
				if let m = message as? Message {
					m.moveToArchive()
				}
			}
		}
	}
	
	func unarchive() {
		if let messages = self.messages {
			for message in messages {
				if let m = message as? Message {
					m.moveToInbox()
				}
			}
		}
	}
	
	func markAsRead() {
		
		guard self.messages != nil  else {
			return
		}
		
		for msg in self.messages! {
			
			let message = msg as? Message
			guard message != nil else	{
				return
			}
			message?.markAsRead()
		}
	}
	
	func markAsUnread(message:Message){
		
		guard (self.messages != nil && message.sent_at != nil) else {
			return
		}
		
		for msg in self.messages! {
			let messageToCompare = msg as? Message
			guard messageToCompare != nil else	{
				return
			}
			
			guard messageToCompare!.sent_at != nil else {
				return
			}
			
			let currentMessageDate = message.sent_at!
			let messageToCompareDate = messageToCompare!.sent_at!
			
			if messageToCompareDate.isLaterThanDate(currentMessageDate) || messageToCompareDate.isEqualToDate(currentMessageDate) {
				messageToCompare!.markAsUnread()
			}
		}
	}
}
