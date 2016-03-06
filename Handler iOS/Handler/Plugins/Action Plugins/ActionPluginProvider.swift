//
//  ActionPluginProvider.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class ActionPluginProvider: NSObject {
    class func messageCellPluginForInboxType(type: MailboxType)->MessageTableViewCellActions?{
        switch type {
        case .Inbox:
            return InboxActionHandler()
        case .Unread:
            return nil
        case .Flagged:
            return nil
        case .Drafts:
            return nil
        case .Sent:
            return nil
        case .Archive:
            return nil
        default:
            return nil
        }
    }
}
