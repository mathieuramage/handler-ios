//
//  User+CoreDataProperties.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var handle: String?
    @NSManaged var profile_picture_url: String?
    @NSManaged var desc: String?
    @NSManaged var provider: String?
    @NSManaged var created_at: NSDate?
    @NSManaged var updated_at: NSDate?
    @NSManaged var sent_messages: NSSet?
    @NSManaged var contacts: NSSet?

}
