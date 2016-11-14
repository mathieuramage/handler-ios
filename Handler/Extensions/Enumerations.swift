//
//  Enumerations.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation



enum MailboxType: String {
	case Inbox = "INBOX"
	case Unread = "UNREAD"
	case Flagged = "IMPORTANT"
	case Drafts = "DRAFT"
	case Sent = "SENT"
	case Archive = "ARCHIVE"
	case AllChanges = ""

	static let allValues = [Inbox, Unread, Flagged, Drafts, Sent, Archive, AllChanges]
}

enum SystemLabels: String {
	case Inbox = "INBOX"
	case Unread = "UNREAD"
	case Flagged = "IMPORTANT"
	case Drafts = "DRAFT"
	case Sent = "SENT"
	case Trashed = "TRASHED"
}

enum TwitterFriendshipStatus: Int {
	case follower = 0
	case following
	case unknown
}
