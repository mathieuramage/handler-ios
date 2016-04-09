//
//  SentMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class SentMailboxViewController: AbstractMailboxViewController {

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Sent
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)

		if segue.identifier == "showThreadTableViewController" {
			let dc = segue.destinationViewController as! ThreadTableViewController
			dc.thread = self.messageForSegue?.thread
			var threads = [Thread]()
			for message in self.fetchedObjects {
				if let thread = message.thread {
					threads.append(thread)
				}
			}
			dc.allThreads = threads

			if let destination = segue.destinationViewController as? ThreadTableViewController {
				destination.primaryMessage = self.messageForSegue!
			}

		} else if segue.identifier == "showMessageComposeNavigationController" {
			let dc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! MessageComposeTableViewController
			dc.draftMessage = self.messageForSegue
		}
	}

	func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
		let view = NSBundle.mainBundle().loadNibNamed("EmptyInboxView", owner: self, options: nil).first as! EmptyInboxView
		view.imageView.image = UIImage(named: "mailbox_sent_empty")
		view.descriptionLabel.text = "Your sent emails will be here."
		view.actionButton.addTarget(self, action: #selector(SentMailboxViewController.composeNewMessage), forControlEvents: .TouchUpInside)
		return view
	}
}
