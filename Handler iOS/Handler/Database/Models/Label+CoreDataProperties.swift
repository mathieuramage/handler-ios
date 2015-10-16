//
//  Label+CoreDataProperties.swift
//  Handler
//
//  Created by Christian Praiss on 16/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Label {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var messages: NSSet?

}
