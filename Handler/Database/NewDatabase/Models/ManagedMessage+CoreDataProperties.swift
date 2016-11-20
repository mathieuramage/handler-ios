//
//  Message+CoreDataProperties.swift
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

extension ManagedMessage {

    @NSManaged var content: String?
	@NSManaged var folderType: String?
	@NSManaged var conversationId: String?
    @NSManaged var identifier : String?
	@NSManaged var createdAt : NSDate?
	@NSManaged var updatedAt : NSDate?
    @NSManaged var shouldBeSent: NSNumber?

	var starred : Bool {
		get {
			willAccessValue(forKey: "starred")
			defer { didAccessValue(forKey: "starred") }
			return primitiveStarred?.boolValue ?? false
		}
		set {
			willChangeValue(forKey:"starred")
			defer { didChangeValue(forKey: "starred") }
			primitiveStarred = NSNumber(value: newValue)
		}
	}
	@NSManaged var primitiveStarred : NSNumber?

	var read : Bool {
		get {
			willAccessValue(forKey: "read")
			defer { didAccessValue(forKey: "read") }
			return primitiveRead?.boolValue ?? false
		}
		set {
			willChangeValue(forKey:"read")
			defer { didChangeValue(forKey: "read") }
			primitiveRead = NSNumber(value: newValue)
		}
	}
	@NSManaged var primitiveRead : NSNumber?


    @NSManaged var subject: String?
    @NSManaged var recipients: NSSet?
	@NSManaged var labels: NSSet?
    @NSManaged var sender: ManagedUser?
    @NSManaged var conversation: ManagedConversation?

	@objc(addRecipientsObject:)
	@NSManaged public func addRecipientsObject(_ value: ManagedUser)

	@objc(removeRecipientsObject:)
	@NSManaged public func removeRecipientsObject(_ value: ManagedUser)

	@objc(addRecipients:)
	@NSManaged public func addRecipients(_ values: NSSet)

	@objc(removeRecipients:)
	@NSManaged public func removeRecipients(_ values: NSSet)
}
