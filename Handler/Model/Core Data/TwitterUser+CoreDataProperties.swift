//
//  TwitterUser+CoreDataProperties.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 17/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData


extension TwitterUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TwitterUser> {
        return NSFetchRequest<TwitterUser>(entityName: "TwitterUser");
    }

    @NSManaged public var username: String?
    @NSManaged public var name: String?
    @NSManaged public var pictureURL: String?
    @NSManaged public var location: String?
    @NSManaged public var bannerURL: String?
    @NSManaged public var url: String?
    @NSManaged public var followerCount: NSNumber?
    @NSManaged public var friendCount: NSNumber?
    @NSManaged public var following: NSNumber?
    @NSManaged public var identifier: String?
    @NSManaged public var desc: String?
    @NSManaged public var user: User?

}
