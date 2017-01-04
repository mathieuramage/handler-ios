//
//  Config.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 10/07/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseRemoteConfig

struct Config {

	static let ClientId = "61e5e9e14a8a79ab6d0e878a59fd610a54fb32dbc9121e4e527864f15f0feb03"
	static let ClientSecret = "206918bd632983a20cc5549ced836ea63fe80803b2ac3f95d044d06296932d75"

	static let APIURL = "https://api.handlerapp.com/"
	static let APIVersion = "api/v1/"

	struct APIRoutes {
		//https://handler.atlassian.net/wiki/display/ENG/Handler+Backends#HandlerBackends-ENDPOINTS

		//OAuth
		static let oauth = "oauth/token"
		static let revoke = "oauth/revoke"

		//Messaging
		static let messages = Config.APIVersion + "messages"
		fileprivate static let message = Config.APIVersion + "messages/:message_id"
		static func message(_ messageId : String) -> String {
			return message.replacingOccurrences(of: ":message_id", with: messageId)
		}

		//Conversations
		fileprivate static let conversations = Config.APIVersion + "conversations/:conversation_id"
		static func conversation(_ conversationId : String) -> String {
			return conversations.replacingOccurrences(of: ":conversation_id", with: conversationId)
		}

		// User Details
		static let user = Config.APIVersion + "users/:user_id"
		static func user(_ userId : String) -> String {
			return user.replacingOccurrences(of: ":user_id", with: userId)
		}

		static let labels = Config.APIVersion + "labels"
	}
	
	struct UserDefaults {
		static let uidKey = "uid"
	}
	
	struct Intercom {
		static let appId = "ibzqbu7k"
		static let apiKey = "ios_sdk-0e8806a76cf019432996c9dd14aa7d27997905ce"
	}
	
	struct Instabug {
		static let apiToken = "bf4b5a418115ba8ffcd30c664085bb23"
	}

	struct Twitter {
		static let consumerKey = "bH6FU5R4bVQ5QJhYvNyFZywFm"
		static let consumerSecret = "64VOfx9rmBBf98v7dNFQa9m4NEKsTpX82JSSyGlN5W4A4i8cTy"

//		static let consumerKey = "H39589t6PVVSCD9nLvPQnYoT6"
//		static let consumerSecret = "GPS9xgLaZ2NQ2ZCunX1AfnyzdP122vARdEGD6m4iJM08Cte9H0"
	}
	struct Firebase {
		struct ParamKeys {
			static let showSupportMenu = "ios_show_support_menu"
			static let attachmentMaxSize = "ios_attachment_max_size"
			static let enableAttachments = "ios_enable_attachments"
		}
		struct RemoteConfig {
			static let instance = FIRRemoteConfig.remoteConfig()
			static let defaultParams: [String : NSObject] = [
				ParamKeys.showSupportMenu : true as NSObject,
				ParamKeys.attachmentMaxSize : 9223372036854775807 as NSObject,
				ParamKeys.enableAttachments : true as NSObject
			]
		}
	}
	struct AppEvents {
		
		struct Mailbox {
			static let contentName = "The different user’s mailboxes"
			static let contentType = "Mailboxes"
			static let inbox = "Inbox" //Views of mailbox Inbox
			static let unread = "Unread" //Views of mailbox Unread
			static let flagged = "Flagged" //Views of mailbox Flagged
			static let drafts = "Drafts" //Views of mailbox Drafts
			static let sent = "Sent" //Views of mailbox Sent
			static let archive = "Archive" //Views of mailbox Archive
		}
		
		struct SideMenu {
			static let contentName = "The user’s main menu"
			static let contentType = "Menu"
			static let logout = "Logout" //Number of log outs
			static let feedback = "Feedback" //Number of feedback emails
			static let viewMenu = "Side Menu" //Views of side menu
		}
		
		struct EmailActions {
			static let contentName = "The user's mails"
			static let contentType = "Emails"
			static let read = "Read" //Actions of emails opened
			static let markRead = "Mark Read" //Actions of emails marked read
			static let markUnread = "Mark Unread" //Actions of emails marked unread
			static let archived = "Archived" //Actions of emails archived
			static let unarchived = "Unarchived" //Actions of emails unarchived
			static let deleted = "Deleted" //Actions of emails deleted
			static let received = "Received" //Actions of emails received
			static let flagged = "Star" //Actions of emails flagged
			static let unflagged = "Unstar" //Actions of emails unflagged
		}
		
		struct Compose {
			static let contentType = "Emails"
			static let contentName = "The user’s compose"
			static let received = "Received" //Number of emails received
			static let read = "Read" //Number of emails read
			static let composed = "Composed" //Number of emails composed
			static let savedDraft = "Save Draft" //Number of email drafts saved
			static let sent = "Sent" //Number of emails sent
			static let notSent = "Not Sent" //Number of emails not sent
			static let replied = "Reply" //Number of emails replied
			static let repliedAll = "Reply All" //Number of emails replied all
			static let forwarded = "Forward" //Number of emails forwarded
		}
		
	}
}

