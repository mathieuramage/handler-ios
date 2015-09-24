//
//  APICommunicator.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import HandlerSDK
import KeychainAccess

class APICommunicator: NSObject {
	static let sharedInstance = APICommunicator()
	
	override init(){
		super.init()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidAuth", name: HRUserSessionDidStartNotification, object: nil)
		
		if let authToken = Keychain(service: "com.handlerapp.Handler")[string: "authToken"], let expirationData = Keychain(service: "com.handlerapp.Handler")[data: "expirationDate"], let expirationDate = NSKeyedUnarchiver.unarchiveObjectWithData(expirationData) as? NSDate {
			if expirationDate.timeIntervalSince1970 <= NSDate().timeIntervalSince1970 {
				print("Session has expired")
				do {
					try Keychain(service: "com.handlerapp.Handler").remove("authToken")
					try Keychain(service: "com.handlerapp.Handler").remove("expirationDate")
				} catch {
					print(error)
				}
				HROAuthManager.startOAuth()
			}else{
				print(authToken)
				HRUserSessionManager.updateCurrentSession(token: authToken, expiryDate: expirationDate)
			}
		}else{
			HROAuthManager.startOAuth()
		}
	}
	
	func checkForCurrentSessionOrAuth(){
		
	}
	
	func userDidAuth(){
		guard let currentSession = HRUserSessionManager.sharedManager.currentSession else {
			print("No current session")
			return
		}
		
		do {
			try Keychain(service: "com.handlerapp.Handler").set(currentSession.authToken, key: "authToken")
			try Keychain(service: "com.handlerapp.Handler").set(NSKeyedArchiver.archivedDataWithRootObject(currentSession.expirationDate), key: "expirationDate")
		} catch {
			print(error)
		}
		
		fetchNewMessage()
		fetchNewLabels()
	}
	
	private func fetchNewLabels(){
		HandlerAPI.getAllLabels { (labels, error) -> Void in
			guard let labels = labels else {
				print(error)
				return
			}
			for label in labels {
				MailDatabaseManager.sharedInstance.storeLabel(label)
			}

		}
	}
	
	private func fetchNewMessage(){
		HandlerAPI.getNewMessageWithCallback() { (messages, error) -> Void in
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
