//
//  APICommunicator.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import HandlerSDK

class APICommunicator: NSObject {
	static let sharedInstance = APICommunicator()
	
	override init(){
		super.init()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidAuth", name: HRUserSessionDidStartNotification, object: nil)
	}
	
	func userDidAuth(){
		fetchNewInboxMessages()
		fetchNewSentMessages()
	}
	
	private func fetchNewSentMessages(){
		HandlerAPI.getNewMessageWithCallback("SENT") { (messages, error) -> Void in
			guard let messages = messages else {
				print(error)
				return
			}
			for message in messages {
				MailDatabaseManager.sharedInstance.storeMessage(message)
			}

		}
	}
	
	private func fetchNewInboxMessages(){
		HandlerAPI.getNewMessageWithCallback(nil) { (messages, error) -> Void in
			guard let messages = messages else {
				print(error)
				return
			}
			for message in messages {
				MailDatabaseManager.sharedInstance.storeMessage(message)
			}
		}
	}
}
