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
		DatabaseManager.sharedInstance.backgroundContext.perform {
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedUser.entityName())
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
			let users: [ManagedUser] = DatabaseManager.sharedInstance.backgroundContext.safeExecuteFetchRequest(fetchRequest)
			for user in users {
				user.twtterFollowStatus = NSNumber(value: TwitterAPIOperations.followStatusForID(user.name!).rawValue as Int)
			}

			DatabaseManager.sharedInstance.backgroundContext.saveRecursively()
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
