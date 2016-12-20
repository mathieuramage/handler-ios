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
	
	static func getAllMessages(before : Date? , after : Date?, limit : Int?, callback : @escaping (_ success : Bool, _ messages : [MessageData]?) -> ()) {
		
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
				var messages : [MessageData] = []
				if let value = response.result.value {
					if let json = JSON(value)["messages"].array {
						for messageJson in json {
                            let message = MessageData(json: messageJson)
							messages.append(message)
						}
					}
				}
					callback(true,messages)

			case .failure(_):
				callback(false,nil)
			}
		}
	}
	
	static func getMessage(_ id : String, callback : @escaping (_ success : Bool, _ message : MessageData?) -> ()) {
		
		let route = Config.APIRoutes.message(id)
		APIUtility.request(method: .get, route: route, parameters: nil).responseJSON { response in
			switch response.result {
			case .success:
				var message : MessageData?
				if let value = response.result.value {
                    message = MessageData(json : JSON(value))
				}
				callback(true,message)
			case .failure(_):
				callback(false,nil)
			}
		}
	}
	
//	static func replyMessageToAll(_ message : Message, replyMessage: String, callback : @escaping MessageUpdateCallback) {
//		var messageData = MessageData()
//		messageData.conversationId = message.conversationId
//		messageData.subject = message.subject
//		messageData.message = replyMessage
//		
//		var recipients : [String] = []
//		
//		if message.sender?.identifier != AuthUtility.user?.identifier {
//			recipients.append(message.sender!.handle)
//		}
//        
//		for user in message.recipients! {
//			if (user as AnyObject).identifier != AuthUtility.user?.identifier {
//				recipients.append((user as AnyObject).handle)
//			}
//		}
//		messageData.recipients = recipients
//		postNewMessage(messageData, callback: callback)
//	}
	
	typealias MessageUpdateCallback = (_ success : Bool, _ message: MessageData?) -> ()
	
	static func replyToUserNames(_ recipientUserNames : [String], conversationId: String, message : String, subject : String, callback : MessageUpdateCallback?) {
		var messageData = MessageUpdateData()
		messageData.subject = message
		messageData.message = subject
		messageData.folder = .Sent
		messageData.recipients = recipientUserNames
		postNewMessage(messageData, callback: callback)
	}
	
	static func sendNewMessage(_ message : String, subject : String, recipientUserNames: [String], callback : MessageUpdateCallback?) {
		var messageData = MessageUpdateData()
		messageData.subject = subject
		messageData.message = message
		messageData.folder = .Sent
		messageData.recipients = recipientUserNames
		postNewMessage(messageData, callback: callback)
	}
	
	static func saveMessageAsDraft(_ message : String?, subject : String?, recipientUserNames : [String], callback : MessageUpdateCallback?) {
		var messageData = MessageUpdateData()
		messageData.subject = subject
		messageData.message = message
		messageData.folder = .Draft
		messageData.recipients = recipientUserNames
		postNewMessage(messageData, callback: callback)
	}
	
	static func updateDraft(_ identifier: String, message : String?, subject : String?, recipientUserNames : [String], callback : MessageUpdateCallback?) {
		var messageData = MessageUpdateData()
		messageData.messageId = identifier
		messageData.subject = subject
		messageData.message = message
		messageData.recipients = recipientUserNames
		postExistingMessage(messageData, callback: callback)
	}
	
	static func sendDraft(_ identifier: String, message : String?, subject : String?, recipientUserNames : [String], callback : MessageUpdateCallback?) {
		var messageData = MessageUpdateData()
		messageData.messageId = identifier
		messageData.subject = subject
		messageData.message = message
		messageData.recipients = recipientUserNames
		messageData.folder = .Sent
		postExistingMessage(messageData, callback: callback)
	}
	
	static func setMessageAsRead(message : Message, read : Bool, callback : MessageUpdateCallback?) {
		var messageData = MessageUpdateData()
		messageData.messageId = message.identifier
		messageData.read = true
		postExistingMessage(messageData, callback: callback)
	}
	
	static func setMessageStarred(message : Message, starred : Bool, callback : MessageUpdateCallback?) {
		var messageData = MessageUpdateData()
		messageData.messageId = message.identifier
		messageData.starred = true
		postExistingMessage(messageData, callback: callback)
	}
	
	static func deleteMessage(messageId: String, callback : MessageUpdateCallback?) {
		var messageData = MessageUpdateData()
		messageData.messageId = messageId
		messageData.folder = .Deleted
		postExistingMessage(messageData, callback: callback)
	}
	
	fileprivate static func postNewMessage(_ messageData : MessageUpdateData, callback : MessageUpdateCallback?) {
		
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
				var message : MessageData?
				if let value = response.result.value {
					message = MessageData(json: JSON(value))
				}
				callback?(true,message)
			case .failure(_):
				callback?(false, nil)
			}
		}
	}
	
	
	fileprivate static func postExistingMessage(_ messageData : MessageUpdateData, callback : MessageUpdateCallback?) {
		
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
				var message : MessageData?
				if let value = response.result.value {
                    message = MessageData(json :JSON(value))
                    callback?(true,message)
				}
				
			case .failure(_):
				callback?(false, nil)
			}
		}
	}
}


private struct MessageUpdateData {
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



struct MessageData {
    var content: String?
    var conversationId: String?
    var createdAt: Date?
    var folderString: String?
    var identifier: String?
    var read: Bool
    var shouldBeSent: Bool
    var starred: Bool
    var subject: String?
    var updatedAt: Date?
    var recipients: [UserData]?
    var sender: UserData?
    var labels: [String]?
    
    init(json: JSON) {
        
        sender = UserData(json: json["sender"])
        conversationId = json["conversationId"].stringValue
        
        subject = json["subject"].stringValue
        content = json["message"].stringValue
        
        recipients = []
        if let recipientJsons = json["recipients"].array {
            for recipientJson in recipientJsons {
                let recipient = UserData(json: recipientJson)
                recipients?.append(recipient)
            }
        }
        
        read = json["isRead"].boolValue
        
        folderString = json["folder"].stringValue
        
        labels = []
        if let labelJsons = json["labels"].array {
            for labelJson in labelJsons {
                labels?.append(labelJson.stringValue)
            }
        }
        
        starred = json["isStar"].boolValue
        
        if let createdAtStr = json["createdAt"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            createdAt = formatter.date(from: createdAtStr)
        } else {
            createdAt = Date()
        }
        
        if let updatedAtStr = json["updatedAt"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            updatedAt = formatter.date(from: updatedAtStr)
        } else {
            updatedAt = Date()
        }
        
        shouldBeSent = json["shouldBeSent"].bool ?? false
    }
}
