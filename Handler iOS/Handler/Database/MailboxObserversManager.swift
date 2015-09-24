//
//  MailboxObserversManager.swift
//  Handler
//
//  Created by Christian Praiss on 24/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class MailboxObserversManager: NSObject {
	static var sharedInstance = MailboxObserversManager()
	
	private var mailBoxes = [MailboxMessagesObserver]()
	
	override init(){
		super.init()
		
		
		for mailboxType in MailboxType.allValues {
			mailBoxes.append(MailboxMessagesObserver(type: mailboxType))
		}
	}
	
	private func mailboxForType(type: MailboxType) -> MailboxMessagesObserver {
		for mailbox in self.mailBoxes {
			if mailbox.type == type {
				return mailbox
			}
		}
		return MailboxMessagesObserver(type: .Inbox)
	}
	
	func addObserverForMailboxType(type: MailboxType, observer: NSFetchedResultsControllerDelegate){
		mailboxForType(type).addObserver(observer)
	}
	
	func addCountObserverForMailboxType(type: MailboxType, observer: MailboxCountObserver){
		mailboxForType(type).addCountObserver(observer)
	}
	
	func fetchedResultsControllerForType(type: MailboxType) -> NSFetchedResultsController {
		return mailboxForType(type).fetchedResultsController
	}
}

private
class MailboxMessagesObserver: NSObject, NSFetchedResultsControllerDelegate {
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		return NSFetchedResultsController(fetchRequest: Message.fetchRequestForMessagesWithInboxType(self.type), managedObjectContext: NSManagedObject.globalManagedObjectContext(), sectionNameKeyPath: nil, cacheName: nil)
		}()
	
	var observers = [NSFetchedResultsControllerDelegate]()
	var countObservers = [MailboxCountObserver]()
	var type: MailboxType
	
	init(type: MailboxType){
		self.type = type
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
		observer.mailboxCountDidChange(type, newCount: fetchedResultsController.fetchedObjects?.count ?? 0)
	}
	
	@objc func controllerWillChangeContent(controller: NSFetchedResultsController) {
		for observer in observers {
			observer.controllerWillChangeContent?(controller)
		}
	}
	
	@objc func controllerDidChangeContent(controller: NSFetchedResultsController) {
		for observer in observers {
			observer.controllerDidChangeContent?(controller)
		}
		
		for observer in countObservers {
			observer.mailboxCountDidChange(type, newCount: controller.fetchedObjects?.count ?? 0)
		}
	}
	
	@objc func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		for observer in observers {
			observer.controller?(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
		}
	}
	
	@objc func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		for observer in observers {
			observer.controller?(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
		}
	}
}