//
//  ConversationManager.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 17/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

struct ConversationDao {
    
    static var inboxFetchRequest : NSFetchRequest<Conversation> = {
        let predicate = NSPredicate(format: "SUBQUERY(messages, $t, $t.folderString == %@).@count != 0", Folder.Inbox.rawValue)
		let fetchRequest : NSFetchRequest<Conversation> = Conversation.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latestMessageDate", ascending: false)]
        return fetchRequest
    }()
    
    
	static func updateOrCreateConversation(conversationData : ConversationData, context : NSManagedObjectContext = CoreDataStack.shared.viewContext) -> Conversation {
        
		let fetchRequest : NSFetchRequest<Conversation> = Conversation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", conversationData.identifier!)
        fetchRequest.fetchBatchSize = 1
		
        if let conversation = (context.safeExecute(fetchRequest) as [Conversation]).first as Conversation? {
            conversation.setConversationData(conversationData)
            return conversation
        }
        
        let conversation = Conversation(data: conversationData, context: context)
		
        return conversation
    }
    
    
    static func archiveConversation(conversation : Conversation, inBackground : Bool = false) {
        
    }
    
    static func unarchiveConversation(conversation : Conversation, inBackground : Bool = false) {
        
    }

}
