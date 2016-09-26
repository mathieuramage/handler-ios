//
//  MessageOperations.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/06/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

struct MessageOperations {

	static func getAllMessages(before before : NSDate? , after : NSDate?, limit : Int?, callback : (success : Bool, messages : [Message]?) -> ()) {

		var params : [String : AnyObject] = [:]

		if let before = before {
			params["before"] = NSDate()
		} else {
			params["before"] = NSDate()
		}
		if let after = after {
			params["after"] = 0 
		} else {
			params["after"] = 0
		}
		if let limit = limit {
			params["limit"] = limit
		}

		APIUtility.request(.GET, route: Config.APIRoutes.messages, parameters: params).responseJSON { (response) in
			switch response.result {
			case .Success:
				var messages : [Message] = []
				if let value = response.result.value {
					if let json = JSON(value)["messages"].array {
						for messageJson in json {
							let message = Message(json: messageJson, inContext: DatabaseManager.sharedInstance.mainManagedContext)
							messages.append(message)
						}
					}
				}
				callback(success: true, messages: messages)
			case .Failure(_):
				callback(success: false, messages: nil)
			}
		}
	}

	static func getMessage(id : String, callback : (success : Bool, message : Message?) -> ()) {

		let route = Config.APIRoutes.message(id)
		APIUtility.request(.GET, route: route, parameters: nil).responseJSON { (response) in
			switch response.result {
			case .Success:
				var message : Message?
				if let value = response.result.value {
					message = Message(json: JSON(value), inContext: DatabaseManager.sharedInstance.mainManagedContext)
				}
				callback(success: true, message: message)
			case .Failure(_):
				callback(success: false, message: nil)
			}
		}
	}

	static func replyMessageToAll(message : Message, replyMessage: String, callback : MessageUpdateCallback) {
		var messageData = MessageData()
		messageData.conversationId = message.conversationId
		messageData.subject = message.subject
		messageData.message = replyMessage

		var recipients : [String] = []

		if message.sender?.identifier != AuthUtility.user?.identifier {
			recipients.append(message.sender!.handle)
		}
		for user in message.recipients! {
			if user.identifier != AuthUtility.user?.identifier {
				recipients.append(user.handle)
			}
		}
		messageData.recipients = recipients
		postNewMessage(messageData, callback: callback)
	}

	typealias MessageUpdateCallback = (success : Bool, message: Message?) -> ()

	static func replyToUserNames(recipientUserNames : [String], conversationId: String, message : String, subject : String, callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.subject = message
		messageData.message = subject
		messageData.folder = .Sent
		messageData.recipients = recipientUserNames
		postNewMessage(messageData, callback: callback)
	}

	static func replyMessageToUsers(users : [ManagedUser], conversationId: String, message: String, subject : String, callback : MessageUpdateCallback?) {
		var recipientUserNames : [String] = []
		for user in users {
			recipientUserNames.append(user.handle)
		}
		replyToUserNames(recipientUserNames, conversationId: conversationId, message: message, subject: subject, callback: callback)
	}

	static func sendNewMessage(message : String, subject : String, recipientUserNames: [String], callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.subject = subject
		messageData.message = message
		messageData.folder = .Sent
		messageData.recipients = recipientUserNames
		postNewMessage(messageData, callback: callback)
	}

	static func sendNewMessage(message : String, subject : String, recipients: [ManagedUser], callback : MessageUpdateCallback?) {
		var recipientUserNames : [String] = []
		for user in recipients {
			recipientUserNames.append(user.handle)
		}
		sendNewMessage(message, subject: subject, recipientUserNames: recipientUserNames, callback: callback)
	}

	static func setMessageAsRead(message message : Message, read : Bool, callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.messageId = message.identifier
		messageData.read = true
		postExistingMessage(messageData, callback: callback)
	}

	static func setMessageStarred(message message : Message, starred : Bool, callback : MessageUpdateCallback?) {
		var messageData = MessageData()
		messageData.messageId = message.identifier
		messageData.starred = true
		postExistingMessage(messageData, callback: callback)
	}


	private static func postNewMessage(messageData : MessageData, callback : MessageUpdateCallback?) {

		let route = Config.APIRoutes.messages

		var params = [String : AnyObject]()

		if let conversationId = messageData.conversationId {
			params["conversation_id"] = conversationId
		}

		if let subject = messageData.subject {
			params["subject"] = subject
		}

		if let message = messageData.message {
			params["message"] = message
		}

		if let folder = messageData.folder {
			params["folder"] = folder.rawValue
		}

		if let recipients = messageData.recipients {
			params["recipients"] = recipients
		}

		if let labels = messageData.labels {
			params["labels"] = labels
		}

		APIUtility.request(.POST, route: route, parameters: params).responseJSON { (response) in
			switch response.result {
			case .Success:
				var message : Message?
				if let value = response.result.value {
					if let json = JSON(value)["messages"].array {
						for messageJson in json {
							message = Message(json: messageJson, inContext: DatabaseManager.sharedInstance.mainManagedContext)
						}
					}
				}
				callback?(success: true, message: message)
			case .Failure(_):
				callback?(success: false, message: nil)
			}
		}
	}


	private static func postExistingMessage(messageData : MessageData, callback : MessageUpdateCallback?) {

		guard let messageId = messageData.messageId else {
			callback?(success : false, message: nil)
			return
		}
		let route = Config.APIRoutes.message(messageId)

		var params = [String : AnyObject]()

		if let subject = messageData.subject {
			params["subject"] = subject
		}

		if let message = messageData.message {
			params["message"] = message
		}

		if let folder = messageData.folder {
			params["folder"] = folder.rawValue
		}

		if let recipients = messageData.recipients {
			params["recipients"] = recipients
		}

		if let read = messageData.read {
			params["isRead"] = read
		}

		if let starred = messageData.starred {
			params["isStar"] = starred
		}

		if let labels = messageData.labels {
			params["labels"] = labels
		}

		APIUtility.request(.POST, route: route, parameters: params).responseJSON { (response) in
			switch response.result {
			case .Success:
				var message : Message?
				if let value = response.result.value {
					if let json = JSON(value)["messages"].array {
						for messageJson in json {
							message = Message(json: messageJson, inContext: DatabaseManager.sharedInstance.mainManagedContext)
						}
					}
				}
				callback?(success: true, message: message)

			case .Failure(_):
				callback?(success: false, message: nil)
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
