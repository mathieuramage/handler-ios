//
//  Message+CoreDataProperties.swift
//  Handler
//
//  Created by Christian Praiss on 16/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LegacyMessage {

    @NSManaged var content: String?
    @NSManaged var id: String?
    @NSManaged var sent_at: NSDate?
    @NSManaged var shouldBeSent: NSNumber?
    @NSManaged var subject: String?
    @NSManaged var actions: HRSendAction?
    @NSManaged var attachments: NSSet?
    @NSManaged var labels: NSSet?
    @NSManaged var recipients: NSSet?
    @NSManaged var sender: ManagedUser? // COMPLETELY WRONG!!!! JUST TO AVOID COMPILER ERRORS FOR TIME BEING
    @NSManaged var thread: Thread?
    @NSManaged var willBeRepliedToInAction: HRSendAction?

}
