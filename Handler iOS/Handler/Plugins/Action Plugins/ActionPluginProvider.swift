//
//  ActionPluginProvider.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class ActionPluginProvider: NSObject {
    class func messageCellPluginForInboxType(type: MailboxType)->MessageTableViewCellActions?{
        switch type {
        case .Inbox:
            return InboxActionHandler()
        case .Unread:
            return UnreadActionHandler()
        case .Flagged:
            return FlaggedActionHandler()
        case .Drafts:
            return DraftsActionHandler()
        case .Sent:
            return SentActionHandler()
        case .Archive:
            return ArchiveActionHandler()
        default:
            return nil
        }
    }
}
