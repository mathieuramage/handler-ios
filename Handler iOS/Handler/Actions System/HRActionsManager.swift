//
//  HRActionsManager.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData

let ActionProgressDidChangeNotification = "ActionProgressDidChange"

class HRActionsManager: NSObject, NSFetchedResultsControllerDelegate {
	private static let sharedInstance = HRActionsManager()
	
	var fetchedResultsController: NSFetchedResultsController?

	class func setupSharedInstance(){
		sharedInstance.configure()
	}
	
	func configure(){
		let fr = NSFetchRequest(entityName: "HRAction")
		let predicate = NSPredicate(format: "running == NO AND completed == NO AND hadError == NO")
		fr.predicate = predicate
		fr.sortDescriptors = [NSSortDescriptor(key: "running", ascending: true)]
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController?.delegate = self
		do {
			try fetchedResultsController?.performFetch()
		} catch {
			print(error)
		}
	}
	
	class func enqueueMessage(message: Message, replyTo: Message? = nil){
		MailDatabaseManager.sharedInstance.backgroundContext.performBlock { () -> Void in
			_ = HRSendAction(message: message, inReplyTo: replyTo)
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		for hrAction in controller.fetchedObjects as! [HRAction] {
			if let running = hrAction.running?.boolValue where !running && hrAction.parentDependency == nil {
				hrAction.execute()
			}
		}
	}
	
	class func stopAll(){
		let fr = NSFetchRequest(entityName: "HRAction")
		let predicate = NSPredicate(format: "running == YES AND completed == NO AND hadError == NO")
		fr.predicate = predicate
		fr.sortDescriptors = [NSSortDescriptor(key: "running", ascending: true)]
		if let results = try? MailDatabaseManager.sharedInstance.managedObjectContext.executeFetchRequest(fr), let convResults = results as? [HRAction] {
			for result in convResults {
				result.running = NSNumber(bool: false)
			}
		}
		MailDatabaseManager.sharedInstance.saveContext()
	}
}
