//
//  Message+CoreDataProperties.swift
//  Handler
//
//  Created by Christian Praiss on 01/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var content: String?
    @NSManaged var id: String?
    @NSManaged var sent_at: NSDate?
    @NSManaged var subject: String?
    @NSManaged var attachments: NSSet?
    @NSManaged var labels: NSSet?
    @NSManaged var recipients: NSSet?
    @NSManaged var sender: User?
    @NSManaged var thread: Thread?

}
