//
//  HRSendAction+CoreDataProperties.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension HRSendAction {

    @NSManaged var message: Message?
    @NSManaged var replyTo: Message?

}
