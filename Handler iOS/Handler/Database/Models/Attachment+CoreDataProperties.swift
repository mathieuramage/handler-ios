//
//  Attachment+CoreDataProperties.swift
//  Handler
//
//  Created by Christian Praiss on 09/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Attachment {

    @NSManaged var content_type: String?
    @NSManaged var filename: String?
    @NSManaged var id: String?
    @NSManaged var size: NSNumber?
    @NSManaged var upload_complete: NSNumber?
    @NSManaged var upload_url: String?
    @NSManaged var url: String?
    @NSManaged var localFileURL: String?
    @NSManaged var contained_in: NSSet?

}
