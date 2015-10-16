//
//  GenericMailboxTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class GenericMailboxTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, SWTableViewCellDelegate, MailboxCountObserver, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
	
	var fetchedResultsController: NSFetchedResultsController {
		get {
			return MailboxObserversManager.sharedInstance.fetchedResultsControllerForType(mailboxType ?? .Inbox)
		}
	}
	
	var mailboxType: MailboxType? {
		didSet{
			self.navigationItem.title = mailboxType?.rawValue.firstCapitalized ?? "Mailbox"
		}
	}
	
	
	var messageForSegue: Message?
	
	var lastupdatedLabel: UILabel?
	var newEmailsLabel: UILabel?
	
	var fetchedObjects: [Message] {
		get {
			return fetchedResultsController.fetchedObjects as? [Message] ?? [Message]()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.tableFooterView = UIView()
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetSource = self
		
		MailboxObserversManager.sharedInstance.addObserverForMailboxType(mailboxType ?? .Inbox, observer: self)
		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(mailboxType ?? .Inbox, observer: self)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
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
			let message = fetchedObjects[indexPath.row]
			messageForSegue = message
			if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MessageTableViewCell {
				cell.message = message
			}
			if mailboxType == .Drafts {
				performSegueWithIdentifier("showMessageComposeNavigationController", sender: self)
			} else if let thread = message.thread where thread.messages?.count > 1 {
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
			newEmailsLabel?.text = "\(newCount) unread emails"
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
			message.isUnread ? message.markAsRead() : message.markAsUnread()
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
				message.isFlagged ? message.unflag() : message.flag()
				break;
			case 2:
				// Archive
				message.isArchived ? message.moveToInbox() : message.moveToArchive()
			default:
				break;
			}
		}
	}
	
	func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
		return true
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)

		if segue.identifier == "showMessageDetailViewController" {
			let dc = segue.destinationViewController as! MessageDetailViewController
			dc.message = self.messageForSegue
		} else if segue.identifier == "showThreadTableViewController" {
			let dc = segue.destinationViewController as! ThreadTableViewController
			dc.thread = self.messageForSegue?.thread
		} else if segue.identifier == "showMessageComposeNavigationController" {
			let dc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! MessageComposeTableViewController
			dc.draftMessage = self.messageForSegue
		}
	}
	
	func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
		return NSAttributedString(string: "Starsky, it seems like this mailbox is empty...", attributes: [NSForegroundColorAttributeName: UIColor.grayColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)])
	}
}
