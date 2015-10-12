//
//  Thread.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData

class Thread: NSManagedObject {
	
	class func fromID(id: String) -> Thread? {
		if let request = self.fetchRequestForID(id){
			do {
				if let threads = try MailDatabaseManager.sharedInstance.backgroundContext.executeFetchRequest(request) as? [Thread], let thread = threads.first {
					return thread
				}
			} catch {
				print(error)
			}
		}
		
		let thread = Thread(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
		thread.id = id
		return thread
	}
	
	var mostRecentMessage: Message? {
			let msgSet = NSSet(set: messages!)
			let messageList = msgSet.allObjects as? [Message]
			let sorted =  messageList?.sort({
				if let firstSent = $0.sent_at, let secondSent = $1.sent_at {
					return firstSent.compare(secondSent) == NSComparisonResult.OrderedDescending
				}
				return true
			})
			return sorted?.first
	}
}
