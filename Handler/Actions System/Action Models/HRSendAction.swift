//
//  HRSendAction.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData
@objc

class HRSendAction: HRAction {
	
	required convenience init(message: ManagedMessage, inReplyTo: ManagedMessage? = nil){
		self.init(managedObjectContext: DatabaseManager.sharedInstance.backgroundContext)
		self.message = message
		self.replyTo = inReplyTo
		DatabaseManager.sharedInstance.mainManagedContext.saveRecursively()
	}
	
	override func execute() {
		print("starting sending")
		self.running = NSNumber(bool: true)

		// OTTODO: Implement?
//		if self.message?.attachments?.count > 0 {
//			for locattachment in self.message?.attachments?.allObjects as! [Attachment] {
//				let action = HRUploadAction(attachment: locattachment)
//				action.execute()
//				self.dependencies = self.dependencies?.setByAddingObject(action)
//			}
//			MailDatabaseManager.sharedInstance.saveContext()
//		}else{
//			send()
//		}
	}
	
	override func dependencyDidComplete(dependency: HRAction) {
		guard let hadErr = dependency.hadError?.boolValue where !hadErr else {
			self.completed = NSNumber(bool: true)
			self.running = NSNumber(bool: false)
			self.hadError = NSNumber(bool: true)
			return
		}
		
		var allfinished = true

		if let dep = self.dependencies {
			for action in dep.allObjects as! [HRAction] {
				if let hadError = action.hadError?.boolValue where hadError {
					print("error sending message \(self.message?.id), aborting...")
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
	
	private func send(){
//		if let message = message {
//			if let replyTo = replyTo {
//				// reply
//				APICommunicator.sharedInstance.replyToMessageWithID(replyTo.id ?? "", reply: message.toHRType(), callback: { (newmessage, error) -> Void in
//					guard let newmessage = newmessage else {
//						if let error = error {
//							self.hadError = NSNumber(bool: true)
//							error.show()
//						}
//						return
//					}
//					self.message?.updateFromHRType(newmessage)
//					self.completed = NSNumber(bool: true)
//					self.running = NSNumber(bool: false)
//					print("sent")
//				})
//			}else{
//				// send
//				APICommunicator.sharedInstance.sendMessage(message.toHRType()) { (newmessage, error) -> Void in
//					guard let newmessage = newmessage else {
//						if let error = error {
//							self.hadError = NSNumber(bool: true)
//							error.show()
//						}
//						return
//					}
//					print("sent")
//					MailDatabaseManager.sharedInstance.storeMessage(newmessage)
//					self.completed = NSNumber(bool: true)
//					self.running = NSNumber(bool: false)
//				}
//			}
//		}else{
//			hadError = NSNumber(bool: true)
//		}
	}
}
