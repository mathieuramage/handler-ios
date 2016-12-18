//
//  Message+CoreDataProperties.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 16/12/2016.
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
    @NSManaged public var folderType: String?
    @NSManaged public var identifier: String?
    @NSManaged public var read: NSNumber?
    @NSManaged public var shouldBeSent: NSNumber?
    @NSManaged public var starred: NSNumber?
    @NSManaged public var subject: String?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var conversation: Conversation?
    @NSManaged public var labels: NSSet?
    @NSManaged public var recipients: NSSet?
    @NSManaged public var sender: User?

}

// MARK: Generated accessors for labels
extension Message {

    @objc(addLabelsObject:)
    @NSManaged public func addToLabels(_ value: Label)

    @objc(removeLabelsObject:)
    @NSManaged public func removeFromLabels(_ value: Label)

    @objc(addLabels:)
    @NSManaged public func addToLabels(_ values: NSSet)

    @objc(removeLabels:)
    @NSManaged public func removeFromLabels(_ values: NSSet)

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
