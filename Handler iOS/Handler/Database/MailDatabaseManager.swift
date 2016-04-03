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
import HandlerSDK

class MailDatabaseManager: NSObject {
    static let sharedInstance = MailDatabaseManager()
    
    // MARK: - Core Data Object Creation Utilities
    
    func storeMessage(message: HRMessage, save: Bool = true){
        backgroundContext.performBlock { () -> Void in
            Message.fromHRType(message)
            if save {
                self.saveBackgroundContext()
            }
        }
    }
    
    func storeLabel(label: HRLabel, save: Bool = true){
        backgroundContext.performBlock { () -> Void in
            Label.fromHRType(label)
            if save {
                self.saveBackgroundContext()
            }
        }
    }
    
    override init(){
        super.init()
        let _ = managedObjectContext
    }
    
    func executeFetchRequest(fetchRequest: NSFetchRequest) -> [AnyObject]? {
        do {
            return try managedObjectContext.executeFetchRequest(fetchRequest)
        } catch {
            return nil
        }
    }
    
    func executeBackgroundFetchRequest(fetchRequest: NSFetchRequest) -> [AnyObject]? {
        do {
            return try backgroundContext.executeFetchRequest(fetchRequest)
        } catch {
            return nil
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("HandlerDatabaseModel", withExtension: "mom")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let containerPath = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.handler.handlerapp")
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = containerPath!.URLByAppendingPathComponent("database.sqlite")
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            let failureReason = "There was an error creating or loading the application's saved data."
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
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        context.parentContext = self.managedObjectContext
        return self.managedObjectContext
    }()
    
    // MARK: - Core Data Saving
    
    func saveContext () {
        managedObjectContext.performBlock { () -> Void in
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()

                } catch {
                    let nserror = error as NSError
                    NSLog("Error saving context \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    func saveBackgroundContext() {
        backgroundContext.performBlock { () -> Void in
            if self.backgroundContext.hasChanges {
                do {
                    try self.backgroundContext.save()
                    try self.managedObjectContext.save()
                } catch {
                    let nserror = error as NSError
                    NSLog("Error saving backgroundContext \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    func flushDatastore(){
        for entity in managedObjectModel.entities {
            deleteDataForEntity(entity.name ?? "")
        }
        backgroundContext.performBlock { () -> Void in
            do {
                try self.backgroundContext.save()
                try self.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Error saving backgroundContext \(nserror), \(nserror.userInfo)")
            }
            APICommunicator.sharedInstance.finishedFlushingStore()
        }
    }
    
    func deleteDataForEntity(entity: String)
    {
        let managedContext = backgroundContext
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Delete all \(entity)s: \(error) \(error.userInfo)")
        }
    }
}
