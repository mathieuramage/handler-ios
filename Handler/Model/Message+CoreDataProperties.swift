//
//  Message+CoreDataProperties.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 20/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }

    @NSManaged public var content: String?
    @NSManaged public var conversationId: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var folderString: String?
    @NSManaged public var identifier: String?
    @NSManaged public var read: Bool
    @NSManaged public var shouldBeSent: Bool
    @NSManaged public var starred: Bool
    @NSManaged public var subject: String?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var conversation: Conversation?
    @NSManaged public var recipients: NSSet?
    @NSManaged public var sender: User?
    @NSManaged public var labels: Label?

}

// MARK: Generated accessors for recipients
extension Message {

    @objc(addRecipientsObject:)
    @NSManaged public func addToRecipients(_ value: User)

    @objc(removeRecipientsObject:)
    @NSManaged public func removeFromRecipients(_ value: User)

    @objc(addRecipients:)
    @NSManaged public func addToRecipients(_ values: NSSet)

    @objc(removeRecipients:)
    @NSManaged public func removeFromRecipients(_ values: NSSet)

}
