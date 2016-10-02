//
//  ManagedLabel+CoreDataProperties.swift
//  
//
//  Created by Otávio on 02/10/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ManagedLabel {

	@NSManaged var id: NSString?
    @NSManaged var message: ManagedMessage?

}
