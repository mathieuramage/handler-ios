//
//  FlaggedMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class FlaggedMailboxViewController: AbstractMailboxViewController {

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Flagged
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

		if segue.identifier == "showConversationTableViewController" {
//			let dc = segue.destinationViewController as! ThreadTableViewController
//			dc.thread = self.messageForSegue?.thread
//
//			var threads = [Thread]()
//			for message in self.fetchedObjects {
//				if let thread = message.thread {
//					threads.append(thread)
//				}
//			}
//			dc.allThreads = threads
////			dc.primaryMessage = self.messageForSegue

			if let destination = segue.destinationViewController as? ConversationTableViewController {
				destination.conversation = activeConversation
			}

		} else if segue.identifier == "showMessageComposeNavigationController" { //TODO : This part will work when we have a bottom bar.
			let dc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! MessageComposeTableViewController
//			dc.draftMessage = self.messageForSegue
		}
	}

	func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
		let view = NSBundle.mainBundle().loadNibNamed("EmptyInboxView", owner: self, options: nil).first as! EmptyInboxView
		view.imageView.image = UIImage(named: "mailbox_flagged_empty")
		view.descriptionLabel.text = "Your flagged emails will be here."
		view.actionButton.setTitle("Compose your first email", forState: .Normal)
		view.actionButton.addTarget(self, action: #selector(FlaggedMailboxViewController.composeNewMessage), forControlEvents: .TouchUpInside)
		return view
	}
}
