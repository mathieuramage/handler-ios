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
	
	private lazy var fetchedResultsController: NSFetchedResultsController = {
		let fr = NSFetchRequest(entityName: "HRAction")
		let predicate = NSPredicate(format: "running == NO AND completed == NO AND hadError == NO")
		fr.predicate = predicate
		fr.sortDescriptors = [NSSortDescriptor(key: "isRunning", ascending: true)]
		let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: NSManagedObject.globalManagedObjectContext(), sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self
		do {
			try frc.performFetch()
		} catch {
			print(error)
		}
		return frc
	}()
	
	class func setupSharedInstance(){
		sharedInstance.configure()
	}
	
	func configure(){
		_ = fetchedResultsController
	}
	
	class func enqueueMessage(message: Message, replyTo: Message? = nil){
		MailDatabaseManager.sharedInstance.backgroundContext.performBlock { () -> Void in
			_ = HRSendAction(message: message, inReplyTo: replyTo)
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		for hrAction in controller.fetchedObjects as! [HRAction] {
			if let running = hrAction.running?.boolValue where !running {
				hrAction.execute()
			}
		}
	}
}
