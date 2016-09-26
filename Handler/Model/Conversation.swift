//
//  Conversation.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 04/09/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

class Conversation: NSObject {
	var identifier : String
	var messages : [Message]

	init(identifier : String, messages : [Message]) {
		self.identifier = identifier
		self.messages = messages
	}

	var latestMessage : Message { //this may be unnecessary
		get {
			var latest = messages[0]
			for message in messages {
				if message.createdAt!.compare(latest.createdAt!) == .OrderedDescending {
					latest = message
				}
			}
			return latest
		}
	}

	var latestUnreadMessage : Message? {
		get {
			var latest : Message?
			for message in messages {

				if message.read {
					continue
				}

				if latest == nil {
					latest = message
					continue
				}

				if message.createdAt!.compare(latest!.createdAt!) == .OrderedDescending {
					latest = message
				}
			}
			return latest
		}
	}


}
