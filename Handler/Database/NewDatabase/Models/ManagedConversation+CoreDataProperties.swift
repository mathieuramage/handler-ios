//
//  Conversation+CoreDataProperties.swift
//  
//
//  Created by Otávio on 18/09/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ManagedConversation {

    @NSManaged var conversationId: String?
    @NSManaged var messsages: Conversation?
	@NSManaged var starred : NSNumber?
	@NSManaged var read : NSNumber?
	
}