//
//  UserTwitterStatusManager.swift
//  Handler
//
//  Created by Christian Praiss on 16/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData

class UserTwitterStatusManager: NSObject {

	class func startUpdating() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserTwitterStatusManager.newDataFetched), name: fetchedTwitterDataNotification, object: nil)
	}

	class func newDataFetched() {
		DatabaseManager.sharedInstance.backgroundContext.performBlock {
			let fetchRequest = NSFetchRequest(entityName: ManagedUser.entityName())
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
			let users: [ManagedUser] = DatabaseManager.sharedInstance.backgroundContext.safeExecuteFetchRequest(fetchRequest)
			for user in users {
				user.twtterFollowStatus = NSNumber(integer: TwitterAPIOperations.followStatusForID(user.name!).rawValue)
			}

			DatabaseManager.sharedInstance.backgroundContext.saveRecursively()
		}
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
}
