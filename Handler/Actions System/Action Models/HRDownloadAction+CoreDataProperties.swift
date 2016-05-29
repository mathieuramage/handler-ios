//
//  HRDownloadAction+CoreDataProperties.swift
//  Handler
//
//  Created by Christian Praiss on 19/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension HRDownloadAction {

    @NSManaged var progress: NSNumber?
    @NSManaged var attachment: Attachment?

}
