//
//  User+CoreDataProperties.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var desc: String?
    @NSManaged public var identifier: String?
    @NSManaged public var isContact: Bool
    @NSManaged public var provider: String?
    @NSManaged public var riskRating: NSNumber?
    @NSManaged public var twitterFollowStatus: NSNumber?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var contacts: NSSet?
    @NSManaged public var received_messages: NSSet?
    @NSManaged public var sent_messages: NSSet?
    @NSManaged public var twitterUser: TwitterUser?

}

// MARK: Generated accessors for contacts
extension User {

    @objc(addContactsObject:)
    @NSManaged public func addToContacts(_ value: User)

    @objc(removeContactsObject:)
    @NSManaged public func removeFromContacts(_ value: User)

    @objc(addContacts:)
    @NSManaged public func addToContacts(_ values: NSSet)

    @objc(removeContacts:)
    @NSManaged public func removeFromContacts(_ values: NSSet)

}

// MARK: Generated accessors for received_messages
extension User {

    @objc(addReceived_messagesObject:)
    @NSManaged public func addToReceived_messages(_ value: Message)

    @objc(removeReceived_messagesObject:)
    @NSManaged public func removeFromReceived_messages(_ value: Message)

    @objc(addReceived_messages:)
    @NSManaged public func addToReceived_messages(_ values: NSSet)

    @objc(removeReceived_messages:)
    @NSManaged public func removeFromReceived_messages(_ values: NSSet)

}

// MARK: Generated accessors for sent_messages
extension User {

    @objc(addSent_messagesObject:)
    @NSManaged public func addToSent_messages(_ value: Message)

    @objc(removeSent_messagesObject:)
    @NSManaged public func removeFromSent_messages(_ value: Message)

    @objc(addSent_messages:)
    @NSManaged public func addToSent_messages(_ values: NSSet)

    @objc(removeSent_messages:)
    @NSManaged public func removeFromSent_messages(_ values: NSSet)

}
