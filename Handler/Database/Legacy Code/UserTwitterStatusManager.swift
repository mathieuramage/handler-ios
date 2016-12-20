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
		NotificationCenter.default.addObserver(self, selector: #selector(UserTwitterStatusManager.newDataFetched), name: NSNotification.Name(rawValue: fetchedTwitterDataNotification), object: nil)
	}

	class func newDataFetched() {
//		PersistenceManager.backgroundContext.perform {
//			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityName())
//			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//			let users: [User] = PersistenceManager.backgroundContext.safeExecuteFetchRequest(fetchRequest)
//			for user in users {
//				user.twtterFollowStatus = NSNumber(value: TwitterAPIOperations.followStatusForID(user.name!).rawValue as Int)
//			}
//			PersistenceManager.backgroundContext.saveRecursively()
//		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
