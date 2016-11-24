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
    
    func fetchedResultsControllerForType(_ mailboxType: MailboxType) -> NSFetchedResultsController<NSFetchRequestResult> {
        return mailboxForType(mailboxType).fetchedResultsController
    }
}

private
class MailboxMessagesObserver: NSObject, NSFetchedResultsControllerDelegate {
    
    var observers = [NSFetchedResultsControllerDelegate]()
    var countObservers = [MailboxCountObserver]()
    var mailboxType: MailboxType
    
    private var _fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController == nil {
            _fetchedResultsController = NSFetchedResultsController(fetchRequest: ManagedMessage.fetchRequestForMessagesWithInboxType(mailboxType), managedObjectContext: DatabaseManager.sharedInstance.mainManagedContext, sectionNameKeyPath: nil, cacheName: nil)
        }
        return _fetchedResultsController!
    }
        
    init(type: MailboxType){
        self.mailboxType = type
        super.init()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    func addObserver(_ observer: NSFetchedResultsControllerDelegate){
        observers.append(observer)
    }
    
    func addCountObserver(_ observer: MailboxCountObserver){
        self.countObservers.append(observer)
        observer.mailboxCountDidChange(self.mailboxType, newCount: self.fetchedResultsController.fetchedObjects?.count ?? 0)
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
