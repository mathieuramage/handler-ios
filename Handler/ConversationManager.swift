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
        DispatchQueue.global().async {
            NotificationCenter.default.post(
                name: conversationUpdateStartedNotification,
                object: nil,
                userInfo: nil)
            
            let currentUpdate = Date()
            MessageOperations.getAllMessages(
                before: currentUpdate,
                after: ConversationManager.latestUpdate,
                limit: 0) { (success, messageDataArray) in
                    guard let messageDataArray = messageDataArray else {
                        if success {
                            latestUpdate = currentUpdate
                            NotificationCenter.default.post(
                                name: conversationUpdateFinishedNotification,
                                object: nil,
                                userInfo: nil)
                        } else {
                            NotificationCenter.default.post(
                                name: conversationUpdateFailedNotification,
                                object: nil,
                                userInfo: nil)
                        }
                        return
                    }
                    
                    latestUpdate = currentUpdate
                    
                    let conversationDataArray = groupMessageData(messageDataArray)
                    let backgroundContext = CoreDataStack.shared.backgroundContext
                    
                    backgroundContext.perform { context in
                        
                        for data in conversationDataArray {
                            let _ = ConversationDao.updateOrCreateConversation(
                                conversationData: data,
                                context: backgroundContext)
                        }
                        
                        do {
                            try backgroundContext.save()
                        } catch {
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(
                                    name: conversationUpdateFailedNotification,
                                    object: nil,
                                    userInfo: nil)
                                let fetchError = error as NSError
                                print("save error in conversation  manager= \(fetchError), \(fetchError.userInfo)")
                            }
                        }
                        
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(
                                name: AbstractMessageMailboxViewController.menuNeedsUpdate,
                                object: nil,
                                userInfo: nil)
                            NotificationCenter.default.post(
                                name: conversationUpdateFinishedNotification,
                                object: nil,
                                userInfo: nil)
                        }
                    }
            }
        }
    }
    
	static func flagConversation(conversation: Conversation) {
		AppAnalytics.fireContentViewEvent(
			contentId: AppEvents.EmailActions.self.flagged,
			event: AppEvents.EmailActions.self)
		markConversationAsStarred(conversation: conversation, flagged: true)
	}
	
	static func unflagConversation(conversation: Conversation) {
		AppAnalytics.fireContentViewEvent(
			contentId: AppEvents.EmailActions.self.unflagged,
			event: AppEvents.EmailActions.self)
		markConversationAsStarred(conversation: conversation, flagged: false)
	}
	
	static func archiveConversation(conversation: Conversation) {
		AppAnalytics.fireContentViewEvent(
			contentId: AppEvents.EmailActions.self.archived,
			event: AppEvents.EmailActions.self)
		markConversationAsArchived(conversation: conversation, archive: true)
	}
	
	static func unarchiveConversation(conversation: Conversation) {
		AppAnalytics.fireContentViewEvent(
			contentId: AppEvents.EmailActions.self.unarchived,
			event: AppEvents.EmailActions.self)
		markConversationAsArchived(conversation: conversation, archive: false)
	}
	
	static func markConversationAsArchived(conversation: Conversation, archive: Bool) {
		ConversationOperations.archiveConversation(conversationId: conversation.identifier!) { (success) in
			if (!success) {
				print("Error while archiving/unarchiving conversation.")
				return
			}
			moveMessages()
		}
		
		func moveMessages() {
			guard let messages = conversation.messages?.allObjects as? [Message] else { return }
			let folderString = archive ? Folder.Archived.rawValue : Folder.Inbox.rawValue
			let messagesData = MessageDao.getMessageDataArray(messages: messages, folderString: folderString, conversationId: conversation.identifier!, starred: nil, read: nil)
			var conversationData = ConversationData()
			conversationData.identifier = conversation.identifier
			conversationData.folder = archive ? .Archived : .Inbox
			conversationData.messages = messagesData
			
			let _ = ConversationDao.updateOrCreateConversation(conversationData: conversationData)
		}
	}
	
	static func markConversationAsStarred(conversation: Conversation, flagged: Bool) {
		ConversationOperations.markConversationStarred(conversationId: conversation.identifier!, starred: flagged) { (success) in
			guard success, let messages = conversation.messages?.allObjects as? [Message] else { return }
			moveMessages()
		}
		
		func moveMessages() {
			guard let messages = conversation.messages?.allObjects as? [Message] else { return }
			
			let messagesData = MessageDao.getMessageDataArray(messages: messages, folderString: nil, conversationId: conversation.identifier!, starred: flagged, read: nil)
			var conversationData = ConversationData()
			conversationData.identifier = conversation.identifier
			conversationData.messages = messagesData
			conversationData.starred = flagged
			
			let _ = ConversationDao.updateOrCreateConversation(conversationData: conversationData)
		}
	}
	
	static func markConversationAsRead(_ conversation : Conversation) {
		ConversationOperations.markConversationAsRead(conversationId: conversation.identifier!, read: true) { (success) in
			guard let messages = conversation.messages?.allObjects as? [Message], success else { return }
			AppAnalytics.fireContentViewEvent(
				contentId: AppEvents.EmailActions.markUnread,
				event: AppEvents.EmailActions.self)
			
			moveMessages()
		}
		
		func moveMessages() {
			guard let messages = conversation.messages?.allObjects as? [Message] else { return }
			
			let messagesData = MessageDao.getMessageDataArray(messages: messages, folderString: nil, conversationId: conversation.identifier!, starred: nil, read: true)
			var conversationData = ConversationData()
			conversationData.identifier = conversation.identifier
			conversationData.messages = messagesData
			
			let _ = ConversationDao.updateOrCreateConversation(conversationData: conversationData)
		}
	}
	
	static func markConversationAsUnread(_ conversation : Conversation) {
		ConversationOperations.markConversationAsRead(conversationId: conversation.identifier!, read: false) { (success) in
			guard let messages = conversation.messages?.allObjects as? [Message], success else { return }
			AppAnalytics.fireContentViewEvent(
				contentId: AppEvents.EmailActions.markUnread,
				event: AppEvents.EmailActions.self)
			
			moveMessages()
		}
		
		func moveMessages() {
			guard let messages = conversation.messages?.allObjects as? [Message] else { return }
			
			let messagesData = MessageDao.getMessageDataArray(messages: messages, folderString: nil, conversationId: conversation.identifier!, starred: nil, read: false)
			var conversationData = ConversationData()
			conversationData.identifier = conversation.identifier
			conversationData.messages = messagesData
			
			let _ = ConversationDao.updateOrCreateConversation(conversationData: conversationData)
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
