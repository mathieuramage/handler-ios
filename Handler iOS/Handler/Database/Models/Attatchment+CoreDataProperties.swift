//
//  Attatchment+CoreDataProperties.swift
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

extension Attatchment {

    @NSManaged var id: String?
    @NSManaged var url: String?
    @NSManaged var filename: String?
    @NSManaged var size: NSNumber?
    @NSManaged var content_type: String?
    @NSManaged var upload_complete: NSNumber?

}
