//
//  UserCoreDataProperties.swift
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

extension ManagedUser {
    
    @NSManaged var identifier: String?
    var handle : String {
        get {
            willAccessValue(forKey: "handle")
            defer { didAccessValue(forKey: "handle") }
            return primitiveHandle ?? ""
        }
        set {
            willChangeValue(forKey:"handle")
            defer { didChangeValue(forKey: "handle") }
            primitiveHandle = newValue
        }
    }
    @NSManaged var primitiveHandle : String?
    @NSManaged var riskRating : NSNumber?
    @NSManaged var created_at: NSDate?
    @NSManaged var desc: String?
    @NSManaged var id: String?
    @NSManaged var isContact: NSNumber?
    @NSManaged var name: String?
    @NSManaged var profile_picture_url: String?
    @NSManaged var provider: String?
    @NSManaged var twtterFollowStatus: NSNumber?
    @NSManaged var updated_at: NSDate?
    @NSManaged var contacts: NSSet?
    @NSManaged var received_messages: NSSet?
    @NSManaged var sent_messages: NSSet?
    
}
