//
//  FormattingPluginProvider.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class FormattingPluginProvider: NSObject {
    class func messageCellPluginForInboxType(type: MailboxType)->MessageTableViewCellFormatter?{
        switch type {
        case .Inbox:
            return InboxFormatter()
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
