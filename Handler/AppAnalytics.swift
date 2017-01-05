//
//  AppAnalytics.swift
//  Handler
//
//  Created by Marco Nascimento on 1/5/17.
//  Copyright © 2017 Handler, Inc. All rights reserved.
//

import Foundation
import Intercom
import Crashlytics
import FirebaseAnalytics

protocol EventsProtocol {
	static var contentName: String { get }
	static var contentType: String { get }
}

typealias EventContentId = String


class AppAnalytics {
	
	/// Fires 3 content view events at once:
	/// * Fabric Answers.
	/// * Intercom.
	/// * Google Firebase.
	///
	/// - Parameters:
	///   - contentId: The unique string id of the event.
	///   - event: Any event struct that follows EventsProtocol.
	///
	static func fireContentViewEvent(contentId: EventContentId, event: EventsProtocol.Type){
		FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
			kFIRParameterItemID: contentId as NSObject,
			kFIRParameterItemName: event.contentName as NSObject,
			kFIRParameterContentType: event.contentType as NSObject
			])
		Intercom.logEvent(withName: contentId)
		Answers.logContentView(withName: event.contentName, contentType: event.contentType, contentId: contentId, customAttributes: nil)
	}
	
	/// Fires 3 login events at once:
	/// * Fabric Answers.
	/// * Intercom.
	/// * Google Firebase.
	///
	static func fireLoginEvent(){
		FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
			kFIRParameterItemID: AppEvents.Login.contentId as NSObject,
			kFIRParameterItemName: AppEvents.Login.contentName as NSObject,
			kFIRParameterContentType: AppEvents.Login.contentType as NSObject
			])
		Intercom.logEvent(withName: AppEvents.Login.contentName)
		Answers.logLogin(withMethod: AppEvents.Login.fabricDigitsId,
		                 success: true,
		                 customAttributes: nil)
	}
}

struct AppEvents {

	struct Login: EventsProtocol {
		static let contentName = "Login"
		static let contentType = "Login"
		static let contentId = "Login"
		
		static let fabricDigitsId = "Digits"
	}
	
	struct Mailbox: EventsProtocol {
		static let contentName = "The different user’s mailboxes"
		static let contentType = "Mailboxes"
		
		static let inbox = "Inbox" //Views of mailbox Inbox
		static let unread = "Unread" //Views of mailbox Unread
		static let flagged = "Flagged" //Views of mailbox Flagged
		static let drafts = "Drafts" //Views of mailbox Drafts
		static let sent = "Sent" //Views of mailbox Sent
		static let archive = "Archive" //Views of mailbox Archive
	}
	
	struct SideMenu: EventsProtocol {
		static let contentName = "The user’s main menu"
		static let contentType = "Menu"
		
		static let logout = "Logout" //Number of log outs
		static let feedback = "Feedback" //Number of feedback emails
		static let viewMenu = "Side Menu" //Views of side menu
	}
	
	struct EmailActions: EventsProtocol {
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
	
	struct Compose: EventsProtocol {
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
