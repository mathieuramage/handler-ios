//
//  HRDownloadAction.swift
//  Handler
//
//  Created by Christian Praiss on 18/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData

class HRDownloadAction: HRAction {

	var downloadManager: DownloadManager?
	
	required convenience init(attachment: Attachment){
		self.init(managedObjectContext: DatabaseManager.sharedInstance.backgroundContext)
		self.attachment = attachment
		
		DatabaseManager.sharedInstance.backgroundContext.saveRecursively()
	}
	
	override func execute() {
        if(!FeaturesManager.attachmentsActivated) {
            return
        }
        
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
