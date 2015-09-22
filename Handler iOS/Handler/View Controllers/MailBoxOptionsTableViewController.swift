//
//  MailBoxOptionsTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 23/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class MailBoxOptionsTableViewController: UITableViewController, MailboxCountObserver {

	@IBOutlet weak var inboxCountLabel: UILabel!
	@IBOutlet weak var unreadCountLabel: UILabel!
	@IBOutlet weak var flaggedCountLabel: UILabel!
	@IBOutlet weak var draftsCountLabel: UILabel!
	@IBOutlet weak var sentCountLabel: UILabel!
	@IBOutlet weak var archiveCountLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		InboxMessagesObserver.sharedInstance.addCountObserver(self)
	}
	
	func mailboxCountDidChange(mailboxType: MailboxType, newCount: Int) {
		switch mailboxType {
			case .Inbox:
			inboxCountLabel.text = "\(newCount)"
			default:
				break;
		}
	}
}
