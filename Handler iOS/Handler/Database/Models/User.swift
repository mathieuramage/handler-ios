//
//  User.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import HandlerSDK

final class User: NSManagedObject, CoreDataConvertible {
	
	typealias HRType = HRUser
	
	required convenience init(hrType user: HRType, managedObjectContext: NSManagedObjectContext){
		self.init(managedObjectContext: managedObjectContext)
		self.id = user.id
		self.desc = user.desc
		self.handle = user.handle
		self.name = user.name
		self.profile_picture_url = user.picture_url
		self.provider = user.provider
		self.created_at = NSDate.fromString(user.created_at)
		self.updated_at = NSDate.fromString(user.updated_at)
	}
}
