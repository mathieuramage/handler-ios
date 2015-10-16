//
//  UserTwitterStatusManager.swift
//  Handler
//
//  Created by Christian Praiss on 16/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class UserTwitterStatusManager: NSObject {
	
	class func startUpdating(){
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "newDataFetched", name: fetchedTwitterDataNotification, object: nil)
	}
	
	class func newDataFetched(){
		MailDatabaseManager.sharedInstance.backgroundContext.performBlock { () -> Void in
			let fetchRequest = NSFetchRequest(entityName: "User")
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
			if let users = MailDatabaseManager.sharedInstance.executeBackgroundFetchRequest(fetchRequest) as? [User] {
				for user in users {
					user.twtterFollowStatus = NSNumber(integer: TwitterAPICommunicator.followStatusForID(user.name!).rawValue)
				}
			}
			MailDatabaseManager.sharedInstance.saveBackgroundContext()
		}
	}
	
	deinit{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
}
