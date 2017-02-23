//
//  FlaggedMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData

class FlaggedMailboxViewController: AbstractMessageMailboxViewController {

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Flagged
		fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: MessageDao.flaggedFetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if segue.identifier == "showConversationTableViewController" {
			let dc = segue.destination as! ConversationTableViewController
			dc.conversation = self.messageForSegue?.conversation
			var threads = [Conversation]()
			for message in self.fetchedObjects {
				if let thread = message.conversation {
					threads.append(thread)
				}
			}
			dc.allConversations = threads

			if let destination = segue.destination as? ConversationTableViewController {
				destination.conversation = messageForSegue?.conversation
			}

		} else if segue.identifier == "showMessageComposeNavigationController" {
			let dc = (segue.destination as! UINavigationController).viewControllers.first as! MessageComposeTableViewController
			dc.draftMessage = self.messageForSegue
		}
	}

	func customViewForEmptyDataSet(_ scrollView: UIScrollView!) -> UIView! {
		let view = Bundle.main.loadNibNamed("EmptyInboxView", owner: self, options: nil)?.first as! EmptyInboxView
		view.imageView.image = UIImage(named: "mailbox_flagged_empty")
		view.descriptionLabel.text = "Your flagged emails will be here."
		view.actionButton.setTitle("Compose your first email", for: UIControlState())
		view.actionButton.addTarget(self, action: #selector(FlaggedMailboxViewController.composeNewMessage), for: .touchUpInside)
		return view
	}
}
