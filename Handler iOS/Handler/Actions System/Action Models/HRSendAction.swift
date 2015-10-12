//
//  HRSendAction.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
@objc

class HRSendAction: HRAction {
	
	required convenience init(message: Message, inReplyTo: Message? = nil){
		self.init(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
		self.message = message
		self.replyTo = inReplyTo
		MailDatabaseManager.sharedInstance.saveContext()

	}
	
	override func execute() {
		print("starting sending")
		self.running = NSNumber(bool: true)
		
		if self.message?.attachments?.count > 0 {
			for locattachment in self.message?.attachments?.allObjects as! [Attachment] {
				let action = HRUploadAction(attachment: locattachment)
				action.execute()
				self.dependencies = self.dependencies?.setByAddingObject(action)
			}
			MailDatabaseManager.sharedInstance.saveContext()
		}else{
			send()
		}
	}
	
	override func dependencyDidComplete(dependency: HRAction) {
		guard let hadErr = dependency.hadError?.boolValue where !hadErr else {
			self.completed = NSNumber(bool: true)
			self.running = NSNumber(bool: false)
			self.hadError = NSNumber(bool: true)
			self.managedObjectContext?.deleteObject(self)
			return
		}
		
		var allfinished = true

		if let dep = self.dependencies {
			for action in dep.allObjects as! [HRAction] {
				if let hadError = action.hadError?.boolValue where hadError {
					print("error sending message \(self.message?.id), aborting...")
					self.managedObjectContext?.deleteObject(self)
				} else if let actioncompleted = action.completed?.boolValue where !actioncompleted, let actionrunning = action.running?.boolValue where actionrunning {
					print("action are still running, waiting")
					allfinished = false
				}
			}
		}
		
		if allfinished {
			print("all actions finished")
			send()
		}
	}
	
	// API Communication
	
	func send(){
		if let message = message {
			if let replyTo = replyTo {
				// reply
				APICommunicator.sharedInstance.replyToMessageWithID(replyTo.id ?? "", reply: message.toHRType(), callback: { (newmessage, error) -> Void in
					guard let newmessage = newmessage else {
						if let error = error {
							self.hadError = NSNumber(bool: true)
							var errorPopup = ErrorPopupViewController()
							errorPopup.error = error
							errorPopup.show()
						}
						return
					}
					self.message?.updateFromHRType(newmessage)
					self.completed = NSNumber(bool: true)
					self.running = NSNumber(bool: false)
					self.managedObjectContext?.deleteObject(self)
					print("sent")
				})
			}else{
				// send
				APICommunicator.sharedInstance.sendMessage(message.toHRType()) { (newmessage, error) -> Void in
					guard let newmessage = newmessage else {
						if let error = error {
							self.hadError = NSNumber(bool: true)
							var errorPopup = ErrorPopupViewController()
							errorPopup.error = error
							errorPopup.show()
						}
						return
					}
					self.message?.updateFromHRType(newmessage)
					self.completed = NSNumber(bool: true)
					self.running = NSNumber(bool: false)
					self.managedObjectContext?.deleteObject(self)
					print("sent")

				}
			}
		}else{
			hadError = NSNumber(bool: true)
		}
	}
}
