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
				if let threads = try MailDatabaseManager.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Thread], let thread = threads.first {
					return thread
				}
			} catch {
				print(error)
			}
		}
		
		let thread = Thread(managedObjectContext: NSManagedObject.globalManagedObjectContext())
		thread.id = id
		return thread
	}
}
