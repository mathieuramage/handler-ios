//
//  FormattingPluginProvider.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class FormattingPluginProvider: NSObject {
//    class func messageContentCellPluginForConversation() -> MessageContentCellFormatter? {
//        return ConversationContentFormatter()
//    }

    class func messageCellPluginForInboxType(_ type: MailboxType) -> MessageTableViewCellFormatter? {
        switch type {
        case .Inbox:
            return InboxFormatter()
        case .Unread:
            return UnreadFormatter()
        case .Flagged:
            return FlaggedFormatter()
        case .Drafts:
            return DraftsFormatter()
        case .Sent:
            return SentFormatter()
        case .Archive:
            return ArchiveFormatter()
        default:
            return nil
        }
    }
}
