//
//  APICommunicator.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import HandlerSDK
import KeychainAccess
import TwitterKit
import Async

enum AuthenticationState: Int {
    case LoggedIn = 0
    case LoginExpired
    case Authenticating
    case LoggedOut
    case LoggingOut
}

typealias APICommunicatorActionRepeat = ()->Void

class APICommunicator: NSObject {
    static let sharedInstance = APICommunicator()
    
    var allowsObjectCreation: Bool {
        get {
            if authenticationState == .LoggedIn {
                return true
            }else{
                return false
            }
        }
    }
    
    private var authenticationState = AuthenticationState.LoggedOut {
        didSet (previous) {
            if previous != authenticationState {
                switch authenticationState {
                case .LoginExpired:
                    attemptRelogin()
                case .LoggingOut:
                    clearUserData()
                case .LoggedIn:
                    uploadToken()
                    fetchNewMessages()
                    fetchNewLabels()                    
                    for action in reloginActionQueue {
                        action()
                    }
                    reloginActionQueue = [APICommunicatorActionRepeat]()
                default:
                    break;
                }
            }
        }
    }
    
    private var reloginActionQueue = [APICommunicatorActionRepeat]()
    
    override init(){
        super.init()
    }
    
    func start(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidAuth", name: HRUserSessionDidStartNotification, object: nil)
    }
    
    func attemptRelogin(){
        authenticationState = .Authenticating
        if let session = Twitter.sharedInstance().sessionStore.session() as? TWTRSession {
            let oauthSigning = TWTROAuthSigning(authConfig:Twitter.sharedInstance().authConfig, authSession:session)
            HRTwitterAuthManager.startAuth(oauthSigning.OAuthEchoHeadersToVerifyCredentials(), callback: { (error, session) -> Void in
                if let error = error {
                    self.authenticationState = .LoggedOut
                    error.show()
                    AppDelegate.sharedInstance().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
                }else if let _ = session {
                    self.authenticationState = .LoggedIn
                }
            });
        }else{
            self.authenticationState = .LoggedOut
            AppDelegate.sharedInstance().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
        }
    }
    
    func clearUserData(){
        do {
            try Keychain(service: "com.handlerapp.Handler").remove("authToken")
            try Keychain(service: "com.handlerapp.Handler").remove("expirationDate")
        } catch {
            print(error)
        }
        for session in Twitter.sharedInstance().sessionStore.existingUserSessions() as! [TWTRSession]  {
            Twitter.sharedInstance().sessionStore.logOutUserID(session.userID)
        }
        HRUserSessionManager.logout()
        MailDatabaseManager.sharedInstance.flushDatastore()
    }
	
	func flushOldArchivedMessages(){
		 MailDatabaseManager.sharedInstance.flushOldArchiveDatastore()
	}
    
    func signOut(){
        if authenticationState != .LoggingOut {
            authenticationState = .LoggingOut
        }
    }
    
    // MARK: Auth
    
    func userDidAuth(){
        guard let currentSession = HRUserSessionManager.sharedManager.currentSession else {
            return
        }
        authenticationState = .LoggedIn
        TwitterAPICommunicator.sharedInstance.getTwitterData()
        do {
            try Keychain(service: "com.handlerapp.Handler").set(currentSession.authToken, key: "authToken")
            try Keychain(service: "com.handlerapp.Handler").set(NSKeyedArchiver.archivedDataWithRootObject(currentSession.expirationDate), key: "expirationDate")
        } catch {
            print(error)
        }
    }
    
    func uploadToken (){
        guard let _ = HRUserSessionManager.sharedManager.currentSession else {
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
    
    func fetchNewMessagesWithCompletion(completion: ((error: HRError?)->Void)? = nil){
        fetchNewMessages(completion)
    }
    
    // MARK: API Communication
    
    private func fetchNewLabels(){
        HandlerAPI.getAllLabels { (labels, error) -> Void in
            guard let labels = labels else {
                if let errorStatus = error?.status where errorStatus == 401 {
                    self.authenticationState = .LoginExpired
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
    
//    private func fetchSend(){
//        HandlerAPI.getNewMessagesWithCallback("SENT") { (messages, error) -> Void in
//            guard let messages = messages else {
//                print(error)
//                if let errorStatus = error?.status where errorStatus == 401 {
//                    self.authenticationState = .LoginExpired
//                }
//                return
//            }
//            for message in messages {
//                MailDatabaseManager.sharedInstance.storeMessage(message)
//            }
//        }
//    }
    
    private func fetchNewMessages(completion: ((error: HRError?)->Void)? = nil){
        HandlerAPI.getNewMessagesWithCallback() { (messages, error) -> Void in
            guard let messages = messages else {
                print(error)
                if let errorStatus = error?.status where errorStatus == 401 {
                    self.authenticationState = .LoginExpired
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
        if authenticationState == .LoginExpired {
            self.reloginActionQueue.append({ ()->Void in
                self.getMessageWithCallback(id, callback: callback)
            })
        } else {
            HandlerAPI.getMessageWithCallback(id) { (message, error) -> Void in
                guard let error = error else{
                    callback(message: message, error: nil)
                    return
                }
                
                if error.status == 401 {
                    self.reloginActionQueue.append({ ()->Void in
                        self.getMessageWithCallback(id, callback: callback)
                    })
                    self.authenticationState = .LoginExpired
                }
            }
        }
    }
    
    func fetchLabelsForMessageWithID(id: String, callback: ((labels: [HRLabel]?, error: HRError?)->Void)){
        if authenticationState == .LoginExpired {
            self.reloginActionQueue.append({ ()->Void in
                self.fetchLabelsForMessageWithID(id, callback: callback)
            })
        } else {
            HandlerAPI.fetchLabelsForMessageWithID(id) { (labels, error) -> Void in
                guard let error = error else{
                    callback(labels: labels, error: nil)
                    return
                }
                
                if error.status == 401 {
                    self.reloginActionQueue.append({ ()->Void in
                        self.fetchLabelsForMessageWithID(id, callback: callback)
                    })
                    self.authenticationState = .LoginExpired
                }
            }
        }
    }
    
    func setLabelsToMessageWithID(id: String, setLabels: [HRLabel], callback: (labels: [HRLabel]?, error: HRError?)->Void){
        if authenticationState == .LoginExpired {
            self.reloginActionQueue.append({ ()->Void in
                self.setLabelsToMessageWithID(id, setLabels: setLabels, callback: callback)
            })
        } else {
            HandlerAPI.setLabelsToMessageWithID(id, labels: setLabels) { (labels, error) -> Void in
                guard let error = error else{
                    callback(labels: labels, error: nil)
                    return
                }
                
                if error.status == 401 {
                    self.reloginActionQueue.append({ ()->Void in
                        self.setLabelsToMessageWithID(id, setLabels: setLabels, callback: callback)
                    })
                    self.authenticationState = .LoginExpired
                }
            }
        }
    }
    
    func replyToMessageWithID(id: String, reply: HRMessage, callback: (message: HRMessage?, error: HRError?)->Void){
        if authenticationState == .LoginExpired {
            self.reloginActionQueue.append({ ()->Void in
                self.replyToMessageWithID(id, reply: reply, callback: callback)
            })
        } else {
            HandlerAPI.replyToMessageWithID(id, reply: reply) { (message, error) -> Void in
                guard let error = error else{
                    callback(message: message, error: nil)
                    return
                }
                
                if error.status == 401 {
                    self.reloginActionQueue.append({ ()->Void in
                        self.replyToMessageWithID(id, reply: reply, callback: callback)
                    })
                    self.authenticationState = .LoginExpired
                }
            }
        }
    }
    
    func sendMessage(sendMessage: HRMessage, callback: (message: HRMessage?, error: HRError?)->Void){
        if authenticationState == .LoginExpired {
            self.reloginActionQueue.append({ ()->Void in
                self.sendMessage(sendMessage, callback: callback)
            })
        } else {
            HandlerAPI.sendMessage(sendMessage) { (message, error) -> Void in
                guard let error = error else{
                    callback(message: message, error: nil)
                    return
                }
                
                if error.status == 401 {
                    self.reloginActionQueue.append({ ()->Void in
                        self.sendMessage(sendMessage, callback: callback)
                    })
                    self.authenticationState = .LoginExpired
                }
            }
        }
    }
    
    func checkUserWithCallback(userHandle: String, callback: (user: HRUser?, error: HRError?)->Void){
        if authenticationState == .LoginExpired {
            self.reloginActionQueue.append({ ()->Void in
                self.checkUserWithCallback(userHandle, callback: callback)
            })
        } else {
            HandlerAPI.checkUserWithCallback(userHandle) { (user, error) -> Void in
                guard let error = error else{
                    callback(user: user, error: nil)
                    return
                }
                
                if error.status == 401 {
                    self.reloginActionQueue.append({ ()->Void in
                        self.checkUserWithCallback(userHandle, callback: callback)
                    })
                    self.authenticationState = .LoginExpired
                }
            }
        }
    }
    
    // MARK: Upload
    
    func createAttachment(fileType: String, filename: String, callback:(attachment: HRAttachment?, error: HRError?)->Void){
        if authenticationState == .LoginExpired {
            self.reloginActionQueue.append({ ()->Void in
                self.createAttachment(fileType, filename: filename, callback: callback)
            })
        } else {
            HandlerAPI.createAttachment(filename, fileType: fileType) { (attachment, error) -> Void in
                guard let error = error else{
                    callback(attachment: attachment, error: nil)
                    return
                }
                
                if error.status == 401 {
                    self.reloginActionQueue.append({ ()->Void in
                        self.createAttachment(fileType, filename: filename, callback: callback)
                    })
                    self.authenticationState = .LoginExpired
                }
            }
        }
    }
    
    func finishedFlushingStore(){
        if authenticationState == .LoggingOut {
            authenticationState = .LoggedOut
        }else{
            print("Why the hell did you flush!?")
        }
    }
}
