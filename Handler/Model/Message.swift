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

    var folder : Folder = .Inbox //TODO
	var read : Bool = false
    var starred : Bool = false
    
    var archived : Bool {
        get {
            return folder == .Archived
        }
    }
    
    var labels : [String] = []
    var recipients : [User] = []
    
    init(json : JSON) {
		identifier = json["_id"].stringValue
		user = User(json: json["_user"])
		sender = User(json : json["_sender"])
        
    }

}


enum Folder : String {
    case Inbox = "inbox"
    case Sent = "sent"
    case Archived = "archived"
    case Deleted = "deleted"
    case Draft = "draft"
}
