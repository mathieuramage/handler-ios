//
//  Message.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/06/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class Message: NSObject {
    
    /*
 _id	ObjectID	Required | Unique
 _user	User	Required
 _sender	User	Required
 conversationId	UUID	Required | Unique | Default: uuid.v4
 subject	String	Required | Default: ""
 message	String	Required | Default: ""
 recipients	[User]	# Can be empty if folder is 'draft'
 isRead	String	Required | Default: false
 folder	String	Required | Default: ‘draft’ | Enum: ['inbox', 'sent', 'archived', 'deleted', 'draft']
 labels	[String]	# Can be empty. Sample: 'job', 'invoices', ...
 isStar	Boolean	# Can be empty.
*/
	
	var identifier : String
	var user : User
	var sender : User
	var conversationId : String

    var folder : Folder
	var read : Bool
    var starred : Bool?
    var archived : Bool {
        get {
            return folder == .Archived
        }
    }
    
    var labels : [String]
    var recipients : [User]
	var subject : String
	var message : String

	var createdAt : NSDate
	var updatedAt : NSDate

    init(json : JSON) {
		identifier = json["_id"].stringValue
		user = User(json: json["_user"])
		sender = User(json : json["sender"])
		conversationId = json["conversationId"].stringValue

		subject = json["subject"].stringValue
		message = json["message"].stringValue

		recipients = []
		if let recipientJsons = json["recipients"].array {
			for recipientJson in recipientJsons {
				recipients.append(User(json: recipientJson))
			}
		}

		read = json["isRead"].boolValue

		folder = Folder(rawValue: json["folder"].stringValue)!

		labels = []
		if let labelJsons = json["labels"].array {
			for labelJson in labelJsons {
				labels.append(labelJson.stringValue)
			}
		}

		starred = json["isStar"].bool


		if let createdAtStr = json["createdAt"].string {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			createdAt = formatter.dateFromString(createdAtStr)!
		} else {
			createdAt = NSDate()
		}

		if let updatedAtStr = json["updatedAt"].string {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			updatedAt = formatter.dateFromString(updatedAtStr)!
		} else {
			updatedAt = NSDate()
		}
    }

}


enum Folder : String {
    case Inbox = "inbox"
    case Sent = "sent"
    case Archived = "archived"
    case Deleted = "deleted"
    case Draft = "draft"
}
