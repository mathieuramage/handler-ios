//
//  ConversationOperations.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 04/09/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct ConversationOperations {

//	static func refreshConversations(callback callback : (success : Bool, allConversations : [Conversation]) -> ()) {
//
//		// OTTODO: Review this
//		let lastUpdated = NSDate.distantPast()
//		getAllConversations(before: NSDate(), after: lastUpdated, limit: nil) { (success, conversations) in
//			if let conversations = conversations where success {
//				APIUtility.allConversations.appendContentsOf(conversations)
//			}
//			callback(success : success, allConversations: APIUtility.allConversations)
//		}
//	}

	static func getAllConversations(before before : NSDate? , after : NSDate?, limit : Int?, callback : (success : Bool, conversations : [Conversation]?) -> ()) {

		MessageOperations.getAllMessages(before: before, after: after, limit: limit) { (success, messages) in
			if let messages = messages {
				callback(success: success, conversations: nil)
			} else {
				callback(success: success, conversations: nil)
			}
		}
	}

	typealias ConversationUpdateCallback = (success : Bool) -> ()

	static func deleteConversation(conversationId conversationId : String, callback : ConversationUpdateCallback?) {
		moveConversationToFolder(conversationId: conversationId, folder: .Deleted, callback: callback)
	}

	static func archiveConversation(conversationId conversationId : String, callback : ConversationUpdateCallback?) {
		moveConversationToFolder(conversationId: conversationId, folder: .Archived, callback: callback)
	}

	static func moveConversationToFolder(conversationId conversationId : String, folder : Folder, callback : ConversationUpdateCallback?) {
		var conversationData = ConversationData(conversationId: conversationId)
		conversationData.folder = folder
		postConversation(conversationData, callback: callback)
	}

	static func markConversationAsRead(conversationId conversationId : String, read : Bool, callback : ConversationUpdateCallback?) {
		var conversationData = ConversationData(conversationId: conversationId)
		conversationData.read = read
		postConversation(conversationData, callback: callback)
	}

	static func markConversationStarred(conversationId conversationId : String, starred : Bool, callback : ConversationUpdateCallback?) {
		var conversationData = ConversationData(conversationId: conversationId)
		conversationData.starred = starred
		postConversation(conversationData, callback: callback)
	}

	static func updateConversationLabels(conversationId conversationId: String, labels : [String], callback : ConversationUpdateCallback?) {
		var conversationData = ConversationData(conversationId: conversationId)
		conversationData.labels = labels
		postConversation(conversationData, callback: callback)
	}


	private static func postConversation(conversationData : ConversationData, callback : ConversationUpdateCallback?) {

		let route = Config.APIRoutes.conversation(conversationData.conversationId)

		var params = [String : AnyObject]()

		if let folder = conversationData.folder {
			params["folder"] = folder.rawValue
		}

		if let read = conversationData.read {
			params["isRead"] = read
		}

		if let labels = conversationData.labels {
			params["labels"] = labels
		}

		if let starred = conversationData.starred {
			params["isStar"] = starred
		}

		APIUtility.request(.POST, route: route, parameters: params).responseJSON { (response) in
			switch response.result {
			case .Success:
				callback?(success: true)
			case .Failure(_):
				callback?(success: false)
			}
		}
	}
}


private struct ConversationData {

	init(conversationId : String) {
		self.conversationId = conversationId
	}

	var conversationId : String
	var folder : Folder?
	var read : Bool?
	var labels : [String]?
	var starred : Bool?
}
