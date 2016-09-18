//
//  Message+CoreDataProperties.swift
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

extension ManagedMessage {

    @NSManaged var content: String?
    @NSManaged var id: String?
    @NSManaged var sent_at: NSDate?
    @NSManaged var shouldBeSent: NSNumber?
    @NSManaged var subject: String?
    @NSManaged var recipients: NSSet?
    @NSManaged var sender: ManagedUser?
    @NSManaged var conversation: ManagedConversation?

}
