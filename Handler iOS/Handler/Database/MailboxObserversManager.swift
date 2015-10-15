//
//  MailboxObserversManager.swift
//  Handler
//
//  Created by Christian Praiss on 24/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData
import Async

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
		return NSFetchedResultsController(fetchRequest: Message.fetchRequestForMessagesWithInboxType(self.type), managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext, sectionNameKeyPath: nil, cacheName: nil)
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
		Async.main { () -> Void in
			self.countObservers.append(observer)
			observer.mailboxCountDidChange(self.type, newCount: self.fetchedResultsController.fetchedObjects?.count ?? 0)
		}
	}
	
	@objc func controllerWillChangeContent(controller: NSFetchedResultsController) {
		Async.main { () -> Void in
			for observer in self.observers {
				observer.controllerWillChangeContent?(controller)
			}
		}
	}
	
	@objc func controllerDidChangeContent(controller: NSFetchedResultsController) {
		Async.main { () -> Void in
			for observer in self.observers {
				observer.controllerDidChangeContent?(controller)
			}
			
			for observer in self.countObservers {
				observer.mailboxCountDidChange(self.type, newCount: controller.fetchedObjects?.count ?? 0)
			}
		}
	}
	
	@objc func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		Async.main { () -> Void in
			for observer in self.observers {
				observer.controller?(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
			}
		}
	}
	
	@objc func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		Async.main { () -> Void in
			for observer in self.observers {
				observer.controller?(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
			}
		}
	}
}