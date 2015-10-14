//
//  HRActionsManager.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

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
}
