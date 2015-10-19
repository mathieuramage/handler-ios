//
//  HRDownloadAction.swift
//  Handler
//
//  Created by Christian Praiss on 18/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData

class HRDownloadAction: HRAction {

	var downloadManager: DownloadManager?
	
	required convenience init(attachment: Attachment){
		self.init(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
		self.attachment = attachment
		
		MailDatabaseManager.sharedInstance.saveBackgroundContext()
	}
	
	override func execute() {
		print("excuted downlaod for \(attachment?.filename)")
		self.running = NSNumber(bool: true)
		do {
			downloadManager = try DownloadManager(action: self) { (success, error) -> Void in
				guard let error = error else{
					self.hadError = NSNumber(bool: !success)
					self.running = NSNumber(bool: false)
					self.completed = NSNumber(bool: true)
					self.parentDependency?.dependencyDidComplete(self)
					return
				}
				print(error)
				self.hadError = NSNumber(bool: true)
				self.completed = NSNumber(bool: true)
				self.running = NSNumber(bool: false)
				self.parentDependency?.dependencyDidComplete(self)
			}
		} catch {
			print(error)
			self.completed = NSNumber(bool: true)
			self.running = NSNumber(bool: false)
			self.hadError = NSNumber(bool: true)
			self.parentDependency?.dependencyDidComplete(self)
		}
	}

}
