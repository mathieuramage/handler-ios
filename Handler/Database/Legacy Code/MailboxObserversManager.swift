//
//  MailboxObserversManager.swift
//  Handler
//
//  Created by Christian Praiss on 24/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData
import Async

class MailboxObserversManager: NSObject {
    static var sharedInstance = MailboxObserversManager()
    
    fileprivate var mailBoxes = [MailboxMessagesObserver]()
    
    override init() {
        super.init()
        
        for mailboxType in MailboxType.allValues {
            mailBoxes.append(MailboxMessagesObserver(type: mailboxType))
        }
    }
    
    fileprivate func mailboxForType(_ mailboxType: MailboxType) -> MailboxMessagesObserver {
        for mailbox in self.mailBoxes {
            if mailbox.mailboxType == mailboxType {
                return mailbox
            }
        }
        return MailboxMessagesObserver(type: .Inbox)
    }
    
    func addObserverForMailboxType(_ mailboxType: MailboxType, observer: NSFetchedResultsControllerDelegate){
        mailboxForType(mailboxType).addObserver(observer)
    }
    
    func addCountObserverForMailboxType(_ mailboxType: MailboxType, observer: MailboxCountObserver){
        mailboxForType(mailboxType).addCountObserver(observer)
    }
    
    func fetchedResultsControllerForType(_ mailboxType: MailboxType) -> NSFetchedResultsController<Message> {
        return mailboxForType(mailboxType).fetchedResultsController
    }
}

private
class MailboxMessagesObserver: NSObject, NSFetchedResultsControllerDelegate {
    
    var observers = [NSFetchedResultsControllerDelegate]()
    var countObservers = [MailboxCountObserver]()
    var mailboxType: MailboxType
    
    private var _fetchedResultsController : NSFetchedResultsController<Message>?
	private var _fechedConversationResultsController: NSFetchedResultsController<Conversation>?
	private var _fechedUnreadConversationResultsController: NSFetchedResultsController<Conversation>?
	
    var fetchedResultsController: NSFetchedResultsController<Message> {
        if _fetchedResultsController == nil && mailboxType != MailboxType.Inbox && mailboxType != MailboxType.Unread {
			let fetchRqst = MessageDao.fetchRequestForMessagesWithInboxType(mailboxType)
			let ctx = CoreDataStack.shared.viewContext
			_fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: fetchRqst, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        }
        return _fetchedResultsController!
    }
	
	var fetchedConversationResultsController: NSFetchedResultsController<Conversation> {
		if _fetchedResultsController == nil && mailboxType == MailboxType.Inbox  {
			let fetchRqst = MessageDao.fetchRequestForConversationWithInboxType(mailboxType)
			let ctx = CoreDataStack.shared.viewContext
			_fechedConversationResultsController = NSFetchedResultsController<Conversation>(fetchRequest: fetchRqst, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
		}
		return _fechedConversationResultsController!
	}
	
	var fetchUnreadConversationResultsController: NSFetchedResultsController<Conversation> {
		if _fechedUnreadConversationResultsController == nil && mailboxType == MailboxType.Unread {
			let fetchRqst = ConversationDao.unreadFetchRequest
			let ctx = CoreDataStack.shared.viewContext
			_fechedUnreadConversationResultsController = NSFetchedResultsController<Conversation>(fetchRequest: fetchRqst, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
		}
		return _fechedUnreadConversationResultsController!
	}
	
    init(type: MailboxType){
        self.mailboxType = type
        super.init()
		
		if mailboxType == MailboxType.Inbox {
			fetchedConversationResultsController.delegate = self
		} else if mailboxType == MailboxType.Unread {
			fetchUnreadConversationResultsController.delegate = self
		} else {
			fetchedResultsController.delegate = self
		}
		
        do {
			if mailboxType == MailboxType.Inbox {
				try fetchedConversationResultsController.performFetch()
			} else if mailboxType == MailboxType.Unread {
				try fetchUnreadConversationResultsController.performFetch()
			} else {
				try fetchedResultsController.performFetch()
			}
        } catch {
            print(error)
        }
    }
    
    func addObserver(_ observer: NSFetchedResultsControllerDelegate){
        observers.append(observer)
    }
    
    func addCountObserver(_ observer: MailboxCountObserver){
        self.countObservers.append(observer)
		if mailboxType == MailboxType.Inbox {
			observer.mailboxCountDidChange(self.mailboxType, newCount: self.fetchedConversationResultsController.fetchedObjects?.count ?? 0)
		} else if mailboxType == MailboxType.Unread {
			observer.mailboxCountDidChange(self.mailboxType, newCount: self.fetchUnreadConversationResultsController.fetchedObjects?.count ?? 0)
		} else {
			observer.mailboxCountDidChange(self.mailboxType, newCount: self.fetchedResultsController.fetchedObjects?.count ?? 0)
		}
		
    }
    
    @objc func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        for observer in self.observers {
            observer.controllerWillChangeContent?(controller)
        }
    }
    
    @objc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        for observer in self.observers {
            observer.controllerDidChangeContent?(controller)
        }
        
        for observer in self.countObservers {
            observer.mailboxCountDidChange(self.mailboxType, newCount: controller.fetchedObjects?.count ?? 0)
        }
    }
    
    @objc func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        for observer in self.observers {
            observer.controller?(controller, didChange: sectionInfo, atSectionIndex: sectionIndex, for: type)
        }
    }
    
    @objc func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        for observer in self.observers {
            observer.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
        }
    }
}
