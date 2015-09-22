//
//  InboxMessagesObserver.swift
//  Handler
//
//  Created by Christian Praiss on 23/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class InboxMessagesObserver: NSObject, NSFetchedResultsControllerDelegate {
	
	static var sharedInstance = InboxMessagesObserver()
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		return NSFetchedResultsController(fetchRequest: Message.fetchRequestForMessagesWithLabelWithId("INBOX"), managedObjectContext: MailDatabaseManager.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
	}()
	
	var observers = [NSFetchedResultsControllerDelegate]()
	var countObservers = [MailboxCountObserver]()
	
	override init(){
		super.init()
		
		fetchedResultsController.delegate = self
		do {
			try fetchedResultsController.performFetch()
		} catch {
			print(error)
		}
	}
	
	func addObserver(observer: NSFetchedResultsControllerDelegate){
		observers.append(observer)
	}
	
	func addCountObserver(observer: MailboxCountObserver){
		countObservers.append(observer)
		observer.mailboxCountDidChange(MailboxType.Inbox, newCount: fetchedResultsController.fetchedObjects?.count ?? 0)
	}
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		for observer in observers {
			observer.controllerWillChangeContent?(controller)
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		for observer in observers {
			observer.controllerDidChangeContent?(controller)
		}
		
		for observer in countObservers {
			observer.mailboxCountDidChange(MailboxType.Inbox, newCount: controller.fetchedObjects?.count ?? 0)
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		for observer in observers {
			observer.controller?(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		for observer in observers {
			observer.controller?(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
		}
	}
}
