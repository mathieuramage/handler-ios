//
//  Label+CoreDataProperties.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 20/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Label {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Label> {
        return NSFetchRequest<Label>(entityName: "Label");
    }

    @NSManaged public var label: String?
    @NSManaged public var message: NSSet?

}

// MARK: Generated accessors for message
extension Label {

    @objc(addMessageObject:)
    @NSManaged public func addToMessage(_ value: Message)

    @objc(removeMessageObject:)
    @NSManaged public func removeFromMessage(_ value: Message)

    @objc(addMessage:)
    @NSManaged public func addToMessage(_ values: NSSet)

    @objc(removeMessage:)
    @NSManaged public func removeFromMessage(_ values: NSSet)

}
