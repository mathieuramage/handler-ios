//
//  InboxTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData
import Async
import Bond
import DZNEmptyDataSet

class InboxTableViewController: UITableViewController, SWTableViewCellDelegate, NSFetchedResultsControllerDelegate, DZNEmptyDataSetSource {

	var threadForSegue: Thread?

	var activeConversation : Conversation?

	var fetchedResultsController: NSFetchedResultsController {
		get {
			return MailboxObserversManager.sharedInstance.fetchedResultsControllerForType(.Inbox)
		}
	}

	var fetchedObjects: [Thread] {
		get {
			return fetchedResultsController.fetchedObjects as? [Thread] ?? [Thread]()
		}
	}

	var progressBar: UIProgressView!
	var lastupdatedLabel: UILabel?
	var newEmailsLabel: UILabel?

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.registerNib(UINib(nibName: "MessageTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MessageTableViewCell")
		tableView.tableFooterView = UIView()
		tableView.emptyDataSetSource = self
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: #selector(InboxTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl!)
		MailboxObserversManager.sharedInstance.addObserverForMailboxType(.Inbox, observer: self)
	}


	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		refresh()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

		navigationItem.rightBarButtonItem?.enabled = true

		lastupdatedLabel = UILabel(frame: CGRectMake(0, 8, 140, 14))
		CurrentStatusManager.sharedInstance.currentStatusSubtitle.observe { text in
			Async.main(block: { () -> Void in
				self.lastupdatedLabel?.text = text
			})
		}
		lastupdatedLabel?.textAlignment = .Center
		lastupdatedLabel?.font = UIFont.systemFontOfSize(14)
		newEmailsLabel = UILabel(frame: CGRectMake(0, 26, 140, 10))
		CurrentStatusManager.sharedInstance.currentStatus.observe { text in
			Async.main(block: { () -> Void in
				self.newEmailsLabel?.text = text
			})
		}
		newEmailsLabel?.textAlignment = .Center
		newEmailsLabel?.font = UIFont.systemFontOfSize(10)
		newEmailsLabel?.textColor = UIColor.darkGrayColor()

		let containerView = UIView(frame: CGRectMake(0, 0, 140, 44))
		containerView.addSubview(lastupdatedLabel!)
		containerView.addSubview(newEmailsLabel!)
		let item = UIBarButtonItem(customView: containerView)

		let composeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(InboxTableViewController.composeNewMessage))

		self.navigationController!.toolbar.items = [space, item, space, composeItem]

		let navigationbarFrame = self.navigationController!.navigationBar.bounds
		navigationController?.navigationBar.clipsToBounds = false
		progressBar = UIProgressView(frame: CGRectMake(0, navigationbarFrame.height - 2.5, navigationbarFrame.width, 2.5))
		progressBar.progressViewStyle = .Bar
		progressBar.progressTintColor = UIColor.whiteColor()
		progressBar.hidden = true

		CurrentStatusManager.sharedInstance.currentUploadProgress.observe { progress in
			Async.main(block: { () -> Void in
				self.progressBar.progress = progress
				self.progressBar.hidden = progress == 0 || progress == 1
			})
		}

		self.navigationController?.navigationBar.addSubview(progressBar)

		if let cells = self.tableView.visibleCells as? [MessageTableViewCell] {
			for cell in cells {
				if let path = tableView.indexPathForCell(cell) where path.row < fetchedObjects.count {
					let conversation = fetchedObjects[path.row]
					InboxMessageTableViewCellHelper.configureCell(cell, conversation: conversation)
				}
			}
		}
	}

	func refresh(control: UIRefreshControl) {
		refresh()
	}

	func refresh() {
		ConversationOperations.getAllConversations(before: NSDate(), after: nil, limit: 0) { (success, conversations) in
			self.refreshControl?.endRefreshing()
		}
	}

	func composeNewMessage() {
		performSegueWithIdentifier("showMessageComposeNavigationController", sender: self)
	}

	@IBAction func showSideMenu(sender: UIBarButtonItem) {
		presentLeftMenuViewController()
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedObjects.count ?? 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell

		if indexPath.row < fetchedObjects.count {
			let conversation = fetchedObjects[indexPath.row]
				InboxMessageTableViewCellHelper.configureCell(cell, conversation: conversation)
		}

		cell.delegate = self
		return cell
	}


	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		for cell in tableView.visibleCells {
			if let cell = cell as? SWTableViewCell {
				cell.hideUtilityButtonsAnimated(true)
			}
		}
		if indexPath.row < fetchedObjects.count {
			navigationItem.rightBarButtonItem?.enabled = false
			activeConversation = fetchedObjects[indexPath.row]
			performSegueWithIdentifier("showConversationTableViewController", sender: self)
		}
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

	// MARK: NSFetchedResultsController Delegate

	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		self.tableView.beginUpdates()
	}

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		self.tableView.endUpdates()
	}

	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		switch type {
		case NSFetchedResultsChangeType.Insert:
			self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
		case NSFetchedResultsChangeType.Delete:
			self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
		default:
			break;
		}
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
		case NSFetchedResultsChangeType.Insert:
			self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
		case NSFetchedResultsChangeType.Delete:
			self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
		case NSFetchedResultsChangeType.Update:
			self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
		case NSFetchedResultsChangeType.Move:
			self.tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
		}
	}

	// MARK: Swipe Cell

	func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
		return true
	}

	func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {

		if let index = tableView.indexPathForCell(cell)?.row {
			let conversation = fetchedObjects[index]

			guard let identifier = conversation.identifier, let read = conversation.latestMessage?.read else {
				return
			}

			ConversationOperations.markConversationAsRead(conversationId: identifier, read: !read, callback: { (success) in
				self.refresh()
			})
		}

	}

	func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
		guard let row = tableView.indexPathForCell(cell)?.row else {
			return
		}

		let conversation = fetchedObjects[row]

		guard let identifier = conversation.identifier else {
			return
		}

		if index == 0 {

			guard let starred = conversation.latestMessage?.starred else {
				return
			}

			ConversationOperations.markConversationStarred(conversationId: identifier, starred: starred, callback: { (success) in
				self.refresh()
			})

		} else if index == 1 {

			ConversationOperations.archiveConversation(conversationId: identifier, callback: { (success) in
				self.refresh()
			})

		}
	}

	func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
		return true
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)
		if segue.identifier == "showConversationTableViewController" {
			if let destination = segue.destinationViewController as? ConversationTableViewController {
				destination.conversation = activeConversation
				// OTTODO: Pass identifier instead of the fetchedSet?
				destination.allConversations = self.fetchedObjects
			}
		}
	}

	// MARK: Empty Dataset DataSource
	func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
		let view = NSBundle.mainBundle().loadNibNamed("EmptyInboxView", owner: self, options: nil).first as! EmptyInboxView
		view.actionButton.addTarget(self, action: #selector(InboxTableViewController.composeNewMessage), forControlEvents: .TouchUpInside)
		return view
	}
}

