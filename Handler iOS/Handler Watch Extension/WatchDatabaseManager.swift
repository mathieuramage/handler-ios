//
//  WatchDatabaseManager.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import WatchKit
import CoreData

class WatchDatabaseManager: NSObject {
	
	func fetchMessages()->[NSManagedObject]? {
		let fetch = NSFetchRequest(entityName: "Message")
		//fetch.predicate = NSPredicate(format: "ANY labels.id == %@", "inbox")
		fetch.sortDescriptors = [NSSortDescriptor(key: "sent_at", ascending: false)]
		return executeFetchRequest(fetch) as? [NSManagedObject]
	}
	
	func executeFetchRequest(fetchRequest: NSFetchRequest) -> [AnyObject]? {
		do {
			return try managedObjectContext.executeFetchRequest(fetchRequest)
		} catch {
			return nil
		}
	}
	
	// MARK: - Core Data stack
	
	lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1]
		}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = NSBundle.mainBundle().URLForResource("HandlerDatabaseModel", withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
		}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		
		let containerPath = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.chrisspraiss.handlerapp")
		
		
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = containerPath!.URLByAppendingPathComponent("database.sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
		} catch {
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			
			// MARK: TODO - Remove for shipping
			abort()
		}
		
		return coordinator
		}()
	
	lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
		}()
	
	// MARK: - Core Data Saving
	
	func saveContext () {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				let nserror = error as NSError
				NSLog("Error saving managedObjectContext \(nserror), \(nserror.userInfo)")
				
				// MARK: TODO - Remove for shipping
				abort()
			}
		}
	}
}
