//
//  ConversationManager.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 21/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

struct ConversationManager {
	
	static let conversationUpdateStartedNotification = Notification.Name("ConversationUpdateStartedNotification")
	static let conversationUpdateFinishedNotification = Notification.Name("ConversationUpdateFinishedNotification")
	static let conversationUpdateFailedNotification = Notification.Name("ConversationUpdateFailedNotification")
	
	
	private static var _latestUpdateKey = "ConversationLatestUpdate"
	static var latestUpdate : Date? {
		get {
			return UserDefaults.standard.object(forKey: _latestUpdateKey) as? Date
		}
		set {
			if let value = newValue {
				UserDefaults.standard.set(value, forKey: _latestUpdateKey)
			} else {
				UserDefaults.standard.removeObject(forKey: _latestUpdateKey)
			}
		}
	}
	
	static func updateConversations(callback : ((_ : Bool) -> ()) = {_ in}) {
		
		NotificationCenter.default.post(name: conversationUpdateStartedNotification, object: nil, userInfo: nil)
		
		let currentUpdate = Date()
		MessageOperations.getAllMessages(before: currentUpdate, after: ConversationManager.latestUpdate, limit: 0) { (success, messageDataArray) in
			guard let messageDataArray = messageDataArray else {
				if success {
					latestUpdate = currentUpdate
					NotificationCenter.default.post(name: conversationUpdateFinishedNotification, object: nil, userInfo: nil)
				} else {
					NotificationCenter.default.post(name: conversationUpdateFailedNotification, object: nil, userInfo: nil)
				}
				return
			}
			
			latestUpdate = currentUpdate
			
			let conversationDataArray = groupMessageData(messageDataArray)
			
			let backgroundContext = CoreDataStack.shared.backgroundContext
			
			backgroundContext.perform { context in
				
				for data in conversationDataArray {
					let _ = ConversationDao.updateOrCreateConversation(conversationData: data, context: backgroundContext)
				}
				
				do {
					try backgroundContext.save()
				} catch {
					DispatchQueue.main.async {
						NotificationCenter.default.post(name: conversationUpdateFailedNotification, object: nil, userInfo: nil)
                        let fetchError = error as NSError
                        print("save error in conversation  manager= \(fetchError), \(fetchError.userInfo)")
					}
				}
				
				
				DispatchQueue.main.async {
					NotificationCenter.default.post(name: conversationUpdateFinishedNotification, object: nil, userInfo: nil)
				}
				
			}
			
		}
	}
	
	static func markConversationAsRead(_ conversation : Conversation) {
		guard let messages = conversation.messages?.allObjects as? [Message] else { return }
		for message in messages {
			MessageManager.markMessageRead(message: message)
		}
	}
	
	static func markConversationAsUnread(_ conversation : Conversation) {
		guard let messages = conversation.messages?.allObjects as? [Message] else { return }
		for message in messages {
			MessageManager.markMessageUnread(message: message)
		}
	}
	
	private static func groupMessageData(_ messages : [MessageData]) -> [ConversationData] {
		var conversationDict : [String : ConversationData] = [:]
		
		for m in messages {
			var conversation : ConversationData
			let cId = m.conversationId!
			
			if conversationDict[cId] == nil {
				conversation = ConversationData()
				conversation.identifier = cId
				conversation.messages = []
				conversationDict[cId] = conversation
			}
			conversationDict[cId]!.messages!.append(m)
		}
		
		return Array(conversationDict.values)
	}
	
}
