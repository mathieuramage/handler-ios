//
//  CoreDataStack.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 16/12/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData
import Async

class CoreDataStack {
    
    private init(){}
    
    static let shared : CoreDataStack = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Handler")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores{ descriptions, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        self.persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge:
            NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType);
        return self.persistentContainer.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge:
            NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType);
        return context
    }()
    
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        viewContext.perform {
            block(self.viewContext)
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
	// MARK: - Core Data Saving

    typealias SimpleCompletionHandler = (_ error: NSError?) -> Void

    
	func flushDatastore(_ completion: SimpleCompletionHandler? = nil) {
		
		
		let fetch : NSFetchRequest<NSFetchRequestResult> = Conversation.fetchRequest()
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		
		let result = try! viewContext.execute(request)
		
		
		let fetch2 : NSFetchRequest<NSFetchRequestResult> = Message.fetchRequest()
		let request2 = NSBatchDeleteRequest(fetchRequest: fetch2)
		
		let result2 = try! viewContext.execute(request2)
		
		
//		for entity in managedObjectModel.entities {
//			if let name = entity.name {
//				deleteDataForEntity(name)
//			}
//		}
//
//		mainManagedContext.saveRecursively { (error) in
//			if let error = error {
//				NSLog("Error saving backgroundContext \(error), \(error.userInfo)")
//			}
//			completion?(error)
//		}
	}

	static func flushOldArchiveDatastore() {
//		backgroundContext.perform { () -> Void in
//			MessageDao.deleteOldArchivedMessages()
//			MessageDao.deleteArchivedMessagesAfter1000()
//
//			self.backgroundContext.saveRecursively { (error) in
//				if let error = error {
//					NSLog("Error saving backgroundContext \(error), \(error.userInfo)")
//				}
//			}
//		}
	}

//	static fileprivate func deleteDataForEntity(_ entity: String) {
//		let managedContext = mainManagedContext
//		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//		fetchRequest.returnsObjectsAsFaults = false
//
//		let results = managedContext.safeExecuteFetchRequest(fetchRequest)
//		for managedObject in results {
//			managedContext.delete(managedObject)
//		}
//	}

}

extension NSManagedObjectContext {
//
//	typealias SaveResurivelyCompletion = (_ error: NSError?) -> Void
//
//	func saveRecursively(_ completion: SaveResurivelyCompletion? = nil) {
//		self.perform { 
//			do {
//				try self.save()
//			}
//			catch let error as NSError {
//				completion?(error)
//
//				return
//			}
//
//			if let parentContext = self.parent {
//				parentContext.saveRecursively(completion)
//			}
//			else {
//				completion?(nil)
//			}
//		}
//	}
//
	func safeExecute<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
		do {
			return try self.fetch(request)
		}
		catch {
			return []
		}
	}
	
	func trySave() {
		if self.hasChanges {
			do {
				try self.save()
			} catch {
				let nserror = error as NSError
				NSLog("🐍 Unable to save context: unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		} else {
			print("❗️Unable to save context: no changes found")
		}
	}
	
}
//
//extension FileManager {
//
//	class func handlerSharedSecureContainer() -> URL? {
//		return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.handler.handlerapp")
//	}

