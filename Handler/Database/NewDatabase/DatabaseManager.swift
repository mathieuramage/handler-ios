//
//  MailDatabaseManager.swift
//  Handler
//
//  Created by Christian Praiss on 18/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData
import Async
import HandleriOSSDK

class DatabaseManager: NSObject {

	static let sharedInstance = DatabaseManager()

	typealias SimpleCompletionHandler = (error: NSError?) -> Void

	override init() {
		super.init()
		let _ = mainManagedContext
	}

	// MARK: - Core Data stack

	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = NSBundle.mainBundle().URLForResource("Handler", withExtension: "mom")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let containerPath = NSFileManager.handlerSharedSecureContainer()

		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = containerPath?.URLByAppendingPathComponent("database.sqlite")
		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
		} catch {
			// MARK: TODO - Remove for shipping
			abort()
		}
		return coordinator
	}()

	private lazy var writerManagedContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		context.persistentStoreCoordinator = self.persistentStoreCoordinator
		return context
	}()

	lazy var mainManagedContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		context.parentContext = self.writerManagedContext
		return context
	}()

	lazy var backgroundContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
		context.parentContext = self.mainManagedContext
		return context
	}()

	// MARK: - Core Data Saving

	func save(completion: SimpleCompletionHandler? = nil) {
		self.mainManagedContext.saveRecursively { (error) in
			if let error = error {
				NSLog("Error saving context \(error), \(error.userInfo)")
			}
		}
	}

	func flushDatastore(completion: SimpleCompletionHandler? = nil) {
		for entity in managedObjectModel.entities {
			if let name = entity.name {
				deleteDataForEntity(name)
			}
		}

		self.backgroundContext.saveRecursively { (error) in
			if let error = error {
				NSLog("Error saving backgroundContext \(error), \(error.userInfo)")
			}

			completion?(error: error)
		}
	}

	func flushOldArchiveDatastore() {
		backgroundContext.performBlock { () -> Void in
			self.deleteOldArchivedMessages()
			self.deleteArchivedMessagesAfter1000()

			self.backgroundContext.saveRecursively { (error) in
				if let error = error {
					NSLog("Error saving backgroundContext \(error), \(error.userInfo)")
				}
			}
		}
	}

	// OTTODO: Revise this implementation
	func deleteDataForEntity(entity: String) {
		let managedContext = backgroundContext
		let fetchRequest = NSFetchRequest(entityName: entity)
		fetchRequest.returnsObjectsAsFaults = false

		do {
			let results = try managedContext.executeFetchRequest(fetchRequest)
			for managedObject in results {
				let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
				managedContext.deleteObject(managedObjectData)
			}
		}
		catch let error as NSError {
			print("Delete all \(entity)s: \(error) \(error.userInfo)")
		}
	}

	func deleteOldArchivedMessages() {
		let managedContext = backgroundContext
		let fetchRequest = NSFetchRequest(entityName: Message.entityName())
		fetchRequest.returnsObjectsAsFaults = false

		let limitDate = NSDate().dateByAddingTimeInterval(-60 * 24 * 60 * 60)
		fetchRequest.predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@ && sent_at < %@", "INBOX", "SENT", limitDate)

		let results = managedContext.safeExecuteFetchRequest(fetchRequest)
		for managedObject in results {
			managedContext.deleteObject(managedObject)
		}
	}

	// Keeps only the most recent 1000 messages
	func deleteArchivedMessagesAfter1000() {
		let managedContext = backgroundContext
		let fetchRequest = NSFetchRequest(entityName: Message.entityName())
		fetchRequest.returnsObjectsAsFaults = false
		fetchRequest.predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@", "INBOX", "SENT")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent_at", ascending: false)]

		let messages: [Message] = managedContext.safeExecuteFetchRequest(fetchRequest)

		if messages.count > 1000 {
			for i in 1000...messages.count - 1 {
				let message = messages[i]
				managedContext.deleteObject(message)
			}
		}
	}
}

extension NSManagedObjectContext {

	typealias SaveResurivelyCompletion = (error: NSError?) -> Void

	func saveRecursively(completion: SaveResurivelyCompletion? = nil) {
		self.performBlock { 
			do {
				try self.save()
			}
			catch let error as NSError {
				completion?(error: error)

				return
			}

			if let parentContext = self.parentContext {
				parentContext.saveRecursively()
			}
			else {
				completion?(error: nil)
			}
		}
	}

	func safeExecuteFetchRequest<T: NSManagedObject>(fetchRequest: NSFetchRequest) -> [T] {
		do {
			return try self.executeFetchRequest(fetchRequest) as! [T]
		}
		catch {
			return []
		}
	}
}

extension NSFileManager {

	class func handlerSharedSecureContainer() -> NSURL? {
		return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.handler.handlerapp")
	}
}
