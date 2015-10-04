//
//  Enumerations.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation



enum MailboxType: String {
	case Inbox = "INBOX"
	case Unread = "UNREAD"
	case Flagged = "IMPORTANT"
	case Drafts = "DRAFT"
	case Sent = "SENT"
	case Archive = "ARCHIVE"
	
	static let allValues = [Inbox, Unread, Flagged, Drafts, Sent, Archive]
}

enum SystemLabels: String {
	case Inbox = "INBOX"
	case Unread = "UNREAD"
	case Flagged = "IMPORTANT"
	case Drafts = "DRAFT"
	case Sent = "SENT"
	case Trashed = "TRASHED"
}