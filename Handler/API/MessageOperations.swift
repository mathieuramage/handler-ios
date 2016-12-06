//
//  MessageOperations.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/06/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

enum MessageLoadingStatusNotification: String {
	case loading = "MessageLoadingStatusNotificationLoading"
	case finished = "MessageLoadingStatusNotificationFinished"
}

struct MessageOperations {
	
	static func getAllMessages(before : Date? , after : Date?, limit : Int?, callback : @escaping (_ success : Bool, _ messages : [Message]?) -> ()) {
		
		var params : [String : Any] = [:]
		
		if let before = before {
			params["before"] = String(before.timeIntervalSince1970 * 1000)
		} else {
			params["before"] = String(Date().timeIntervalSince1970 * 1000)
		}
		if let after = after {
			params["after"] =  String(after.timeIntervalSince1970 * 1000)
		} else {
			params["after"] = "0"
		}
		if let limit = limit {
			params["limit"] = limit
		}

		NotificationCenter.default.post(name: Notification.Name(MessageLoadingStatusNotification.loading.rawValue), object: nil)
		APIUtility.request(method: .get, route: Config.APIRoutes.messages, parameters: params).responseJSON { response in

			NotificationCenter.default.post(name: Notification.Name(MessageLoadingStatusNotification.finished.rawValue), object: nil)

			switch response.result {
			case .success:
				var messages : [Message] = []
				if let value = response.result.value {
					if let json = JSON(value)["messages"].array {
						for messageJson in json {
							let message = Message.messageWithJSON(messageJson, inContext: DatabaseManager.sharedInstance.mainManagedContext)
							messages.append(message)
						}
					}
				}
				DatabaseManager.sharedInstance.mainManagedContext.saveRecursively{ error in
					callback(true,messages)
				}
			case .failure(_):
				callback(false,nil)
			}
		}
	}
	
	static func getMessage(_ id : String, callback : @escaping (_ success : Bool, _ message : Message?) -> ()) {
		
		let route = Config.APIRoutes.message(id)
		APIUtility.request(method: .get, route: route, parameters: nil).responseJSON { response in
			switch response.result {
			case .success:
				var message : Message?
				if let value = response.result.value {
					message = Message.messageWithJSON(JSON(value), inContext: DatabaseManager.sharedInstance.mainManagedContext)
				}
				callback(true,message)
			case .failure(_):
				callback(false,nil)
			}
		}
	}
	
	static func replyMessageToAll(_ message : Message, replyMessage: String, callback : @escaping MessageUpdateCallback) {
		var messageData = MessageData()
		messageData.conversationId = message.conversationId
		messageData.subject = message.subject
		messageData.message = replyMessage
		
		var recipients : [String] = []
		
		if message.sender?.identifier != AuthUtility.user?.identifier {
			recipients.append(message.sender!.handle)
		}
		for user in message.recipients! {
			if (user as AnyObject).identifier != AuthUtility.user?.identifier {
				recipients.append((user as AnyObject).handle)
			}
		}
		messageData.recipients = recipients
		postNewMessage(messageData, callback: callback)
	}
	
	typealias MessageUpdateCallback = (_ success : Bool, _ message: Message?) -> ()
	
	static func replyToUserNames(_ recipientUserNames : [String], conversationId: String, message : String, subject : String, callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.subject = message
		messageData.message = subject
		messageData.folder = .Sent
		messageData.recipients = recipientUserNames
		postNewMessage(messageData, callback: callback)
	}
	
	static func replyMessageToUsers(_ users : [ManagedUser], conversationId: String, message: String, subject : String, callback : MessageUpdateCallback?) {
		var recipientUserNames : [String] = []
		for user in users {
			recipientUserNames.append(user.handle)
		}
		replyToUserNames(recipientUserNames, conversationId: conversationId, message: message, subject: subject, callback: callback)
	}
	
	static func sendNewMessage(_ message : String, subject : String, recipientUserNames: [String], callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.subject = subject
		messageData.message = message
		messageData.folder = .Sent
		messageData.recipients = recipientUserNames
		postNewMessage(messageData, callback: callback)
	}
	
	static func sendNewMessage(_ message : String, subject : String, recipients: [ManagedUser], callback : MessageUpdateCallback?) {
		var recipientUserNames : [String] = []
		for user in recipients {
			recipientUserNames.append(user.handle)
		}
		sendNewMessage(message, subject: subject, recipientUserNames: recipientUserNames, callback: callback)
	}
	
	static func saveMessageAsDraft(_ message : String?, subject : String?, recipientUserNames : [String], callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.subject = subject
		messageData.message = message
		messageData.folder = .Draft
		messageData.recipients = recipientUserNames
		postNewMessage(messageData, callback: callback)
	}
	
	static func updateDraft(_ identifier: String, message : String?, subject : String?, recipientUserNames : [String], callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.messageId = identifier
		messageData.subject = subject
		messageData.message = message
		messageData.recipients = recipientUserNames
		postExistingMessage(messageData, callback: callback)
	}
	
	static func sendDraft(_ identifier: String, message : String?, subject : String?, recipientUserNames : [String], callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.messageId = identifier
		messageData.subject = subject
		messageData.message = message
		messageData.recipients = recipientUserNames
		messageData.folder = .Sent
		postExistingMessage(messageData, callback: callback)
	}
	
	static func setMessageAsRead(message : Message, read : Bool, callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.messageId = message.identifier
		messageData.read = true
		postExistingMessage(messageData, callback: callback)
	}
	
	static func setMessageStarred(message : Message, starred : Bool, callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.messageId = message.identifier
		messageData.starred = true
		postExistingMessage(messageData, callback: callback)
	}
	
	static func deleteMessage(messageId: String, callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.messageId = messageId
		messageData.folder = .Deleted
		postExistingMessage(messageData, callback: callback)
	}
	
	fileprivate static func postNewMessage(_ messageData : MessageData, callback : MessageUpdateCallback?) {
		
		let route = Config.APIRoutes.messages
		
		var params = [String : AnyObject]()
		
		if let conversationId = messageData.conversationId {
			params["conversation_id"] = conversationId as AnyObject?
		}
		
		if let subject = messageData.subject {
			params["subject"] = subject as AnyObject?
		}
		
		if let message = messageData.message {
			params["message"] = message as AnyObject?
		}
		
		if let folder = messageData.folder {
			params["folder"] = folder.rawValue as AnyObject?
		}
		
		if let recipients = messageData.recipients {
			params["recipients"] = recipients as AnyObject?
		}
		
		if let labels = messageData.labels {
			params["labels"] = labels as AnyObject?
		}
		
		APIUtility.request(method: .post, route: route, parameters: params).responseJSON { response in
			switch response.result {
			case .success:
				var message : Message?
				if let value = response.result.value {
					message = Message.messageWithJSON(JSON(value), inContext: DatabaseManager.sharedInstance.mainManagedContext)
				}
				callback?(true,message)
			case .failure(_):
				callback?(false, nil)
			}
		}
	}
	
	
	fileprivate static func postExistingMessage(_ messageData : MessageData, callback : MessageUpdateCallback?) {
		
		guard let messageId = messageData.messageId else {
			callback?(false, nil)
			return
		}
		let route = Config.APIRoutes.message(messageId)
		
		var params = [String : AnyObject]()
		
		if let subject = messageData.subject {
			params["subject"] = subject as AnyObject?
		}
		
		if let message = messageData.message {
			params["message"] = message as AnyObject?
		}
		
		if let folder = messageData.folder {
			params["folder"] = folder.rawValue as AnyObject?
		}
		
		if let recipients = messageData.recipients {
			params["recipients"] = recipients as AnyObject?
		}
		
		if let read = messageData.read {
			params["isRead"] = read as AnyObject?
		}
		
		if let starred = messageData.starred {
			params["isStar"] = starred as AnyObject?
		}
		
		if let labels = messageData.labels {
			params["labels"] = labels as AnyObject?
		}
		
		APIUtility.request(method: .post, route: route, parameters: params).responseJSON { (response) in
			switch response.result {
			case .success:
				var message : Message?
				if let value = response.result.value {
					message = Message.messageWithJSON(JSON(value), inContext: DatabaseManager.sharedInstance.mainManagedContext)
					DatabaseManager.sharedInstance.mainManagedContext.saveRecursively{ error in
						callback?(true,message)
					}
				}
				
			case .failure(_):
				callback?(false, nil)
			}
		}
	}
}


private struct MessageData {
	var conversationId : String?
	var messageId : String?
	var recipients : [String]?
	var subject : String?
	var message : String?
	var read : Bool?
	var starred : Bool?
	var folder : Folder?
	var labels : [String]?
}
