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
		fetchedResultsController = NSFetchedResultsController<Message>(
			fetchRequest: MessageDao.flaggedFetchRequest,
			managedObjectContext: CoreDataStack.shared.viewContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let space = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
			target: nil,
			action: nil)
		
		navigationItem.rightBarButtonItem?.isEnabled = true
		
		lastupdatedLabel = UILabel(frame: CGRect(x: 0, y: 8, width: 140, height: 14))
		lastupdatedLabel?.textAlignment = .center
		lastupdatedLabel?.font = UIFont.systemFont(ofSize: 11)
		lastupdatedLabel?.textColor = UIColor(rgba: HexCodes.darkGray)
		
		let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 44))
		containerView.addSubview(lastupdatedLabel!)
		let item = UIBarButtonItem(customView: containerView)
		
		let composeItem = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.compose,
			target: self,
			action: #selector(InboxTableViewController.composeNewMessage))
		
		self.navigationController!.toolbar.items = [space, item, space, composeItem]
		showTitleFadeIn(title: "Flagged")
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
		}
	}
	
	func customViewForEmptyDataSet(_ scrollView: UIScrollView!) -> UIView! {
		let view = Bundle.main.loadNibNamed("EmptyInboxView", owner: self, options: nil)?.first as! EmptyInboxView
		view.imageView.image = UIImage(named: "mailbox_flagged_empty")
		view.descriptionLabel.text = "Your flagged emails will be here."
		view.actionButton.setTitle("Compose your first email", for: UIControlState())
		view.actionButton.addTarget(
			self,
			action: #selector(FlaggedMailboxViewController.composeNewMessage),
			for: .touchUpInside)
		
		return view
	}
}
