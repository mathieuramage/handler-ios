//
//  InboxTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class InboxTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, SWTableViewCellDelegate, MailboxCountObserver {
	
	var fetchedResultsController: NSFetchedResultsController {
		get {
			return MailboxObserversManager.sharedInstance.fetchedResultsControllerForType(.Inbox)
		}
	}
	
	var messageForSegue: Message?
	
	var lastupdatedLabel: UILabel?
	var newEmailsLabel: UILabel?
	
	var invitationsView: ErrorPopupView?

	var fetchedObjects: [Message] {
		get {
			return fetchedResultsController.fetchedObjects as? [Message] ?? [Message]()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.tableFooterView = UIView()
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl!)
		
		MailboxObserversManager.sharedInstance.addObserverForMailboxType(.Inbox, observer: self)
		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(.Inbox, observer: self)
	}
	
	func refresh(control: UIRefreshControl){
		APICommunicator.sharedInstance.fetchNewMessagseWithCompletion { (error) -> Void in
			control.endRefreshing()
			guard let error = error else {
				return
			}
			print(error.detail)

		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		
		
		lastupdatedLabel = UILabel(frame: CGRectMake(0, 8, 140, 14))
		lastupdatedLabel?.text = "Updated just now"
		lastupdatedLabel?.textAlignment = .Center
		lastupdatedLabel?.font = UIFont.systemFontOfSize(14)
		newEmailsLabel = UILabel(frame: CGRectMake(0, 26, 140, 10))
		newEmailsLabel?.text = "No new emails"
		newEmailsLabel?.textAlignment = .Center
		newEmailsLabel?.font = UIFont.systemFontOfSize(10)
		newEmailsLabel?.textColor = UIColor.darkGrayColor()
		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(.Unread, observer: self)

		let containerView = UIView(frame: CGRectMake(0, 0, 140, 44))
		containerView.addSubview(lastupdatedLabel!)
		containerView.addSubview(newEmailsLabel!)
		let item = UIBarButtonItem(customView: containerView)
		
		let composeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "composeNewMessage:")
		
		self.navigationController!.toolbar.items = [space, item, space, composeItem]

	}
	
	func composeNewMessage(item: UIBarButtonItem){
		performSegueWithIdentifier("showMessageComposeNavigationController", sender: self)
	}
	
	@IBAction func showSideMenu(sender: UIBarButtonItem) {
		presentLeftMenuViewController()
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ?? 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath) as! MessageTableViewCell
		cell.message = fetchedResultsController.fetchedObjects![indexPath.row] as? Message
		cell.leftUtilityButtons = cell.leftButtons()
		cell.rightUtilityButtons = cell.rightButtons()
		cell.delegate = self
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row < fetchedObjects.count {
			let message = fetchedObjects[indexPath.row]
			messageForSegue = message
			if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MessageTableViewCell {
				cell.message = message
			}
			if let thread = message.thread where thread.messages?.count > 1 {
				performSegueWithIdentifier("showThreadTableViewController", sender: self)
			}else{
				performSegueWithIdentifier("showMessageDetailViewController", sender: self)
			}
		}
	}
	
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
	
	func mailboxCountDidChange(mailboxType: MailboxType, newCount: Int) {
		if mailboxType == MailboxType.Unread {
			if newCount != 0 {
				let emailsText = newCount == 1 ? "email" : "emails"
				newEmailsLabel?.text = "\(newCount) unread " + emailsText
			}else{
				newEmailsLabel?.text = "No new emails"
			}
		}
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
	func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
		return true
	}
	
	func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
		if let cell = cell as? MessageTableViewCell, let message = cell.message {
			message.markAsUnread()
			cell.message = message
		}
	}
	
	func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
		if let cell = cell as? MessageTableViewCell, let message = cell.message {
			switch index {
			case 0:
				// More
				let alert = MessageActionsAlertController(message: message, vc: self)
				presentViewController(alert, animated: true, completion: nil)
				break;
			case 1:
				// Flag
				message.flag()
				break;
			case 2:
				// Archive
				message.moveToArchive()
			default:
				break;
			}
		}
	}
	
	func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
		return true
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMessageDetailViewController" {
			let dc = segue.destinationViewController as! MessageDetailViewController
			dc.message = self.messageForSegue
		} else if segue.identifier == "showThreadTableViewController" {
			let dc = segue.destinationViewController as! ThreadTableViewController
			dc.thread = self.messageForSegue?.thread
		}
	}
}
