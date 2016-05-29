//
//  HRUploadAction.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData
@objc

class HRUploadAction: HRAction {
	
	var uploadManager: UploadManager?
	
	required convenience init(attachment: Attachment){
		self.init(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
		self.attachment = attachment
		attachment.actions = self
	}
	
	override func execute() {
        if(!FeaturesManager.attachmentsActivated) {
            return
        }
        
		self.running = NSNumber(bool: true)
		if let id = attachment?.id where id != "" {
			startUpload()
		}else{
			print("creating attachment on api")
			
			APICommunicator.sharedInstance.createAttachment(attachment?.getMime() ?? "", filename: attachment?.filename ?? "", callback: { (newattachment, error) -> Void in
				if let completed = self.completed where !completed.boolValue {
					guard let newattachment = newattachment else{
						if let error = error {
							self.completed = NSNumber(bool: true)
							self.running = NSNumber(bool: false)
							self.hadError = NSNumber(bool: true)
							self.parentDependency?.dependencyDidComplete(self)
							print(error)
						}
						return
					}
					self.attachment?.updateFromHRType(newattachment)
					self.startUpload()
				}
			})
			
		}
	}
	
	private func startUpload(){
		print("starting upload")
		do {
			uploadManager = try UploadManager(action: self) { (success, error) -> Void in
				guard let error = error else{
					self.hadError = NSNumber(bool: !success)
					self.running = NSNumber(bool: false)
					self.completed = NSNumber(bool: true)
					self.parentDependency?.dependencyDidComplete(self)
					return
				}
				print(error)
				self.hadError = NSNumber(bool: true)
				self.running = NSNumber(bool: false)
				self.completed = NSNumber(bool: true)
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
