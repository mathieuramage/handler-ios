//
//  HRAction+CoreDataProperties.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension HRAction {

    @NSManaged var completed: NSNumber?
    @NSManaged var hadError: NSNumber?
    @NSManaged var queuedOn: NSDate?
    @NSManaged var running: NSNumber?
    @NSManaged var dependencies: NSSet?
    @NSManaged var parentDependency: HRAction?

}
