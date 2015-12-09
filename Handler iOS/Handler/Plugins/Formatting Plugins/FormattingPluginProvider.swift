//
//  FormattingPluginProvider.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class FormattingPluginProvider: NSObject {
    class func messageContentCellPluginForConversation()->MessageContentCellFormatter?{
        return MessageContentFormatter()
    }

    class func messageCellPluginForInboxType(type: MailboxType)->MessageTableViewCellFormatter?{
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
