//
//  MessageDao.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 17/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

struct MessageDao {
    
    
    static func updateOrCreateMessage(messageData : MessageData) -> Message {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", messageData.identifier!)
        fetchRequest.fetchBatchSize = 1
        
        if let message = (PersistenceManager.mainManagedContext.safeExecuteFetchRequest(fetchRequest) as [Message]).first as Message? {
            user.setUserData(messageData)
            return message
        }
        
        let message = Message(data: messageData, context: PersistenceManager.mainManagedContext)
        return message
    }
    
    
    static func deleteOldArchivedMessages() {
        let managedContext = PersistenceManager.backgroundContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
        fetchRequest.returnsObjectsAsFaults = false
        
        let limitDate = Date().addingTimeInterval(-60 * 24 * 60 * 60)
        fetchRequest.predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@ && createdAt < %@", "INBOX", "SENT", limitDate as CVarArg)
        
        let results = managedContext.safeExecuteFetchRequest(fetchRequest)
        for managedObject in results {
            managedContext.delete(managedObject)
        }
    }
    
    // Keeps only the most recent 1000 messages
    static func deleteArchivedMessagesAfter1000() {
        
        let managedContext = PersistenceManager.backgroundContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "NONE labels.id == %@ && NONE labels.id == %@", "INBOX", "SENT")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let messages: [Message] = managedContext.safeExecuteFetchRequest(fetchRequest)
        
        if messages.count > 1000 {
            for i in 1000...messages.count - 1 {
                let message = messages[i]
                managedContext.delete(message)
            }
        }
    }
    
    static func fetchRequestForMessagesWithInboxType(_ type: MailboxType) -> NSFetchRequest<NSFetchRequestResult> {
        
        switch type {
        case .AllChanges :
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
            fetchRequest.fetchBatchSize = 20
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return fetchRequest
            
        case .Inbox :
            let predicate = NSPredicate(format: "SUBQUERY(messages, $t, $t.folderType == %@).@count != 0", Folder.Inbox.rawValue)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Conversation.entityName())
            fetchRequest.fetchBatchSize = 20
            fetchRequest.predicate = predicate
            // OTTODO: It should be sorted by date.
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
            return fetchRequest
            
        case .Unread :
            let predicate = NSPredicate(format: "SUBQUERY(messages, $t, $t.read != nil && $t.read == NO).@count != 0")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Conversation.entityName())
            fetchRequest.predicate = predicate
            fetchRequest.fetchBatchSize = 20
            // OTTODO: It should be sorted by date.
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
            return fetchRequest
            
        case .Sent :
            let predicate = NSPredicate(format: "folderType == %@", Folder.Sent.rawValue)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return fetchRequest
            
        case .Flagged:
            let predicate = NSPredicate(format: "starred != nil && starred == YES")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return fetchRequest
            
        case .Drafts:
            let predicate = NSPredicate(format: "folderType == %@", Folder.Draft.rawValue)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return fetchRequest
            
        default :
            if type != .Archive {
                return fetchRequestForMessagesWithLabelWithId(type.rawValue)
            } else {
                // handle archive case
                let predicate = NSPredicate(format: "folderType == %@", Folder.Archived.rawValue)
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
                fetchRequest.fetchBatchSize = 20
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                return fetchRequest
            }
        }
        
    }
    
    static func fetchRequestForMessagesWithLabelWithId(_ id: String) -> NSFetchRequest<NSFetchRequestResult> {
        let predicate = NSPredicate(format: "ANY labels.id == %@", id)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Message.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return fetchRequest
    }
    
}
