//
//  MessageManager.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 13/01/2017.
//  Copyright © 2017 Handler, Inc. All rights reserved.
//

import UIKit

struct MessageManager {
	
	static func sendNewMessage(content : String, subject : String, recipients : [String], callback : @escaping (_ message : Message?) -> () = {_ in}) {
		
		MessageOperations.sendNewMessage(content, subject: subject, recipientUserNames: recipients) { (success, messageData) in
			
			guard success else { callback(nil); return }
			
			var message : Message?
			if let data = messageData {
				message = MessageDao.updateOrCreateMessage(messageData: data)
			}
			callback(message)
		}
	}
	
	static func replyToConversation(conversationId : String, content : String, subject : String, recipients : [String], callback : @escaping (_ message : Message?) -> () = {_ in}) {
		
		MessageOperations.replyToConversation(conversationId: conversationId, message: content, subject: subject, recipientUserNames: recipients) { (success, messageData) in
			
			guard success else { callback(nil); return }
			
			var message : Message?
			if let data = messageData {
				message = MessageDao.updateOrCreateMessage(messageData: data)
			}
			callback(message)
		}
	}
	
	static func sendDraft(messageId : String, content : String, subject : String, recipients : [String], callback : @escaping (_ message : Message?) -> () = {_ in}) {
		
		MessageOperations.sendDraft(messageId, message: content, subject: subject, recipientUserNames: recipients) { (success, messageData) in
			
			guard success else { callback(nil); return }
			
			var message : Message?
			if let data = messageData {
				message = MessageDao.updateOrCreateMessage(messageData: data)
			}
			callback(message)
		}
	}
	
	static func markMessageRead(message: Message) {
		markMessage(message, asRead: true)
	}
	
	static func markMessageUnread(message: Message) {
		markMessage(message, asRead: false)
	}
	
	static func flagMessage(message: Message) {
		flagMessage(message, flagged: true)
	}
	
	static func unflagMessage(message: Message) {
		flagMessage(message, flagged: false)
	}
	
	private static func flagMessage(_ message : Message, flagged : Bool) {
		message.starred = flagged
		MessageOperations.setMessageStarred(message: message, starred: flagged) { (success, messageData) in
			if let data = messageData {
				let _ = MessageDao.updateOrCreateMessage(messageData: data)
			} else {
				// TODO handle failure
			}
		}
	}
	
	private static func markMessage(_ message : Message, asRead read : Bool) {
		message.read = read
		MessageOperations.setMessageAsRead(message: message, read: read) { (success, messageData) in
			if let data = messageData {
				let _ = MessageDao.updateOrCreateMessage(messageData: data)
			} else {
				// TODO handle failure
			}
		}
	}
	
}
