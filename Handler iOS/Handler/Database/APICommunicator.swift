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
import TwitterKit

class APICommunicator: NSObject {
	static let sharedInstance = APICommunicator()
	
	override init(){
		super.init()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidAuth", name: HRUserSessionDidStartNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidSet", name: HRCurrentUserDidSetNotification, object: nil)
		checkForCurrentSessionOrAuth()
	}
	
	func signOut(){
		do {
			try Keychain(service: "com.handlerapp.Handler").remove("authToken")
			try Keychain(service: "com.handlerapp.Handler").remove("expirationDate")
		} catch {
			print(error)
		}
		if let session = Twitter.sharedInstance().sessionStore.session() {
			Twitter.sharedInstance().sessionStore.logOutUserID(session.userID)
		}
		MailDatabaseManager.sharedInstance.deleteStore()
		HRUserSessionManager.logout()
	}
	
	// MARK: Auth
	
	func checkForCurrentSessionOrAuth(completion: ((error: HRError?)->Void)? = nil){
		if let authToken = Keychain(service: "com.handlerapp.Handler")[string: "authToken"], let expirationData = Keychain(service: "com.handlerapp.Handler")[data: "expirationDate"], let expirationDate = NSKeyedUnarchiver.unarchiveObjectWithData(expirationData) as? NSDate {
			if expirationDate.timeIntervalSince1970 <= NSDate().timeIntervalSince1970 {
				print("Session has expired")
				do {
					try Keychain(service: "com.handlerapp.Handler").remove("authToken")
					try Keychain(service: "com.handlerapp.Handler").remove("expirationDate")
				} catch {
					print(error)
				}
				if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {
					let oauthSigning = TWTROAuthSigning(authConfig:Twitter.sharedInstance().authConfig, authSession:session)
					HRTwitterAuthManager.startAuth(oauthSigning.OAuthEchoHeadersToVerifyCredentials(), callback: { (error, session) -> Void in
						completion?(error: nil)
						if let error = error {
							print(error)
                            AppDelegate.sharedInstance().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
						}
					})
				}else{
					AppDelegate.sharedInstance().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
				}
			}else{
                // TODO: Remove for production
				print(authToken)
				HRUserSessionManager.updateCurrentSession(token: authToken, expiryDate: expirationDate)
				completion?(error: nil)
			}
		}else{
			if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {
				let oauthSigning = TWTROAuthSigning(authConfig:Twitter.sharedInstance().authConfig, authSession:session)
				HRTwitterAuthManager.startAuth(oauthSigning.OAuthEchoHeadersToVerifyCredentials(), callback: { (error, session) -> Void in
					completion?(error: error)
					if let error = error {
						print(error)
                        AppDelegate.sharedInstance().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
					}
				})
			}else{
				AppDelegate.sharedInstance().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
			}
		}
	}
	
	func userDidAuth(){
		guard let currentSession = HRUserSessionManager.sharedManager.currentSession else {
			print("No current session")
			return
		}
		
		TwitterAPICommunicator.sharedInstance.getTwitterData()
		
		do {
			try Keychain(service: "com.handlerapp.Handler").set(currentSession.authToken, key: "authToken")
			try Keychain(service: "com.handlerapp.Handler").set(NSKeyedArchiver.archivedDataWithRootObject(currentSession.expirationDate), key: "expirationDate")
		} catch {
			print(error)
			
		}
        uploadToken()
        fetchNewMessages(nil)
		fetchNewLabels()
		fetchSend()
	}
    
    func uploadToken (){
        guard let _ = HRUserSessionManager.sharedManager.currentSession else {
            print("No current session")
            return
        }
        if let pushToken = NSUserDefaults.standardUserDefaults().stringForKey("pushtoken") where pushToken != "" {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("pushtoken")
            var data: [String: String] = ["token": pushToken, "os": "ios", "os_version": UIDevice.currentDevice().systemVersion, "name":UIDevice.currentDevice().name]
            if let vendorID = UIDevice.currentDevice().identifierForVendor?.UUIDString {
                data["deviceId"] = vendorID
            }
            HandlerAPI.uploadDeviceData(data)
        }
    }
	
	func userDidSet(){
		if let _ = HRUserSessionManager.sharedManager.currentUser {
//			Track.identify(user.id)
//			Track.updateUserData(["userData":user])
		}
	}
	
	func fetchNewMessagseWithCompletion(completion: (error: HRError?)->Void){
		fetchNewMessages(completion)
	}
	
	// MARK: API Communication
	
	private func fetchNewLabels(){
		HandlerAPI.getAllLabels { (labels, error) -> Void in
			guard let labels = labels else {
				if let errorStatus = error?.status where errorStatus == 401 {
					self.checkForCurrentSessionOrAuth({ (error) -> Void in
						self.fetchNewLabels()
					})
				}else if let error = error {
					ErrorHandler.performErrorActions(error)
				}
				return
			}
			for label in labels {
                MailDatabaseManager.sharedInstance.storeLabel(label, save: false)
			}
			
		}
	}
	
	private func fetchSend(){
		HandlerAPI.getNewMessagesWithCallback("SENT") { (messages, error) -> Void in
			guard let messages = messages else {
				print(error)
				if let errorStatus = error?.status where errorStatus == 401 {
					self.checkForCurrentSessionOrAuth({ (error) -> Void in
						self.fetchNewLabels()
					})
				}
				return
			}
			for message in messages {
				MailDatabaseManager.sharedInstance.storeMessage(message)
			}
		}
	}
	
	private func fetchNewMessages(completion: ((error: HRError?)->Void)?){
		HandlerAPI.getNewMessagesWithCallback() { (messages, error) -> Void in
			guard let messages = messages else {
				print(error)
				if let errorStatus = error?.status where errorStatus == 401 {
					self.checkForCurrentSessionOrAuth({ (error) -> Void in
						self.fetchNewLabels()
					})
				}else{
					completion?(error: error)
				}
				return
			}
			for message in messages {
                MailDatabaseManager.sharedInstance.storeMessage(message, save: false)
			}
			completion?(error: nil)
		}
	}
	
	func getMessageWithCallback(id: String, callback: (message: HRMessage?, error: HRError?)->Void){
		HandlerAPI.getMessageWithCallback(id) { (message, error) -> Void in
			guard let error = error else{
				callback(message: message, error: nil)
				return
			}
			
			if error.status == 401 {
				self.checkForCurrentSessionOrAuth({ (error) -> Void in
					self.getMessageWithCallback(id, callback: callback)
				})
			}
		}
	}
	
	func fetchLabelsForMessageWithID(id: String, callback: ((labels: [HRLabel]?, error: HRError?)->Void)){
		HandlerAPI.fetchLabelsForMessageWithID(id) { (labels, error) -> Void in
			guard let error = error else{
				callback(labels: labels, error: nil)
				return
			}
			
			if error.status == 401 {
				self.checkForCurrentSessionOrAuth({ (error) -> Void in
					self.fetchLabelsForMessageWithID(id, callback: callback)
				})
			}
		}
	}
	
	func setLabelsToMessageWithID(id: String, setLabels: [HRLabel], callback: (labels: [HRLabel]?, error: HRError?)->Void){
		HandlerAPI.setLabelsToMessageWithID(id, labels: setLabels) { (labels, error) -> Void in
			guard let error = error else{
				callback(labels: labels, error: nil)
				return
			}
			
			if error.status == 401 {
				self.checkForCurrentSessionOrAuth({ (error) -> Void in
					self.setLabelsToMessageWithID(id, setLabels: setLabels , callback: callback)
				})
			}
			
		}
	}
	
	func replyToMessageWithID(id: String, reply: HRMessage, callback: (message: HRMessage?, error: HRError?)->Void){
		HandlerAPI.replyToMessageWithID(id, reply: reply) { (message, error) -> Void in
			guard let error = error else{
				callback(message: message, error: nil)
				return
			}
			
			if error.status == 401 {
				self.checkForCurrentSessionOrAuth({ (error) -> Void in
					self.replyToMessageWithID(id, reply: reply, callback: callback)
				})
			}
		}
	}
	
	func sendMessage(sendMessage: HRMessage, callback: (message: HRMessage?, error: HRError?)->Void){
		HandlerAPI.sendMessage(sendMessage) { (message, error) -> Void in
			guard let error = error else{
				callback(message: message, error: nil)
				return
			}
			
			if error.status == 401 {
				self.checkForCurrentSessionOrAuth({ (error) -> Void in
					self.sendMessage(sendMessage, callback: callback)
				})
			}
		}
	}
	
	func checkUserWithCallback(userHandle: String, callback: (user: HRUser?, error: HRError?)->Void){
		HandlerAPI.checkUserWithCallback(userHandle) { (user, error) -> Void in
			guard let error = error else{
				callback(user: user, error: nil)
				return
			}
			
			if error.status == 401 {
				self.checkForCurrentSessionOrAuth({ (error) -> Void in
					self.checkUserWithCallback(userHandle, callback: callback)
				})
			}
		}
	}
	
	// MARK: Upload
	
	func createAttachment(fileType: String, filename: String, callback:(attachment: HRAttachment?, error: HRError?)->Void){
		HandlerAPI.createAttachment(filename, fileType: fileType) { (attachment, error) -> Void in
			guard let error = error else{
				callback(attachment: attachment, error: nil)
				return
			}
			
			if error.status == 401 {
				self.checkForCurrentSessionOrAuth({ (error) -> Void in
					if let error = error {
						error.show()
						return
					}
					self.createAttachment(fileType, filename: filename, callback: callback)
				})
			}
		}
	}
}
