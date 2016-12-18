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

struct PersistenceManager {

	typealias SimpleCompletionHandler = (_ error: NSError?) -> Void

	// MARK: - Core Data stack

	static var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: "Handler", withExtension: "mom")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()

	static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let containerPath = FileManager.handlerSharedSecureContainer()

		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		let url = containerPath?.appendingPathComponent("database.sqlite")
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
		} catch {
			// MARK: TODO - Remove for shipping
			abort()
		}
		return coordinator
	}()

	static fileprivate var writerManagedContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		return context
	}()

	static var mainManagedContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.parent = writerManagedContext
		return context
	}()

	static var backgroundContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
		context.parent = mainManagedContext
		return context
	}()

	// MARK: - Core Data Saving

	static func save(_ completion: SimpleCompletionHandler? = nil) {
		mainManagedContext.saveRecursively { (error) in
			if let error = error {
				NSLog("Error saving context \(error), \(error.userInfo)")
			}
		}
	}

	static func flushDatastore(_ completion: SimpleCompletionHandler? = nil) {
		for entity in managedObjectModel.entities {
			if let name = entity.name {
				deleteDataForEntity(name)
			}
		}

		mainManagedContext.saveRecursively { (error) in
			if let error = error {
				NSLog("Error saving backgroundContext \(error), \(error.userInfo)")
			}
			completion?(error)
		}
	}

	static func flushOldArchiveDatastore() {
		backgroundContext.perform { () -> Void in
			self.deleteOldArchivedMessages()
			self.deleteArchivedMessagesAfter1000()

			self.backgroundContext.saveRecursively { (error) in
				if let error = error {
					NSLog("Error saving backgroundContext \(error), \(error.userInfo)")
				}
			}
		}
	}

	static fileprivate func deleteDataForEntity(_ entity: String) {
		let managedContext = mainManagedContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
		fetchRequest.returnsObjectsAsFaults = false

		let results = managedContext.safeExecuteFetchRequest(fetchRequest)
		for managedObject in results {
			managedContext.delete(managedObject)
		}
	}

	static func deleteOldArchivedMessages() {
		let managedContext = backgroundContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
		fetchRequest.returnsObjectsAsFaults = false

		let limitDate = Date().addingTimeInterval(-60 * 24 * 60 * 60)
		fetchRequest.predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@ && createdAt < %@", "INBOX", "SENT", limitDate as CVarArg)

		let results = managedContext.safeExecuteFetchRequest(fetchRequest)
		for managedObject in results {
			managedContext.delete(managedObject)
		}
	}

	// Keeps only the most recent 1000 messages
	static func deleteArchivedMessagesAfter1000() {
		let managedContext = backgroundContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
		fetchRequest.returnsObjectsAsFaults = false
		fetchRequest.predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@", "INBOX", "SENT")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

		let messages: [Message] = managedContext.safeExecuteFetchRequest(fetchRequest)

		if messages.count > 1000 {
			for i in 1000...messages.count - 1 {
				let message = messages[i]
				managedContext.delete(message)
			}
		}
	}
}

extension NSManagedObjectContext {

	typealias SaveResurivelyCompletion = (_ error: NSError?) -> Void

	func saveRecursively(_ completion: SaveResurivelyCompletion? = nil) {
		self.perform { 
			do {
				try self.save()
			}
			catch let error as NSError {
				completion?(error)

				return
			}

			if let parentContext = self.parent {
				parentContext.saveRecursively(completion)
			}
			else {
				completion?(nil)
			}
		}
	}

	func safeExecuteFetchRequest<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [T] {
		do {
			return try self.fetch(fetchRequest) as! [T]
		}
		catch {
			return []
		}
	}
}

extension FileManager {

	class func handlerSharedSecureContainer() -> URL? {
		return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.handler.handlerapp")
	}
}
