//
//  Conversation+CoreDataProperties.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 16/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData


extension Conversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conversation> {
        return NSFetchRequest<Conversation>(entityName: "Conversation");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var read: NSNumber?
    @NSManaged public var starred: NSNumber?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension Conversation {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
