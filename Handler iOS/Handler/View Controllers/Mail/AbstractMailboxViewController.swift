//
//  AbstractMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class AbstractMailboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, SWTableViewCellDelegate, MailboxCountObserver, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
	
	var fetchedResultsController: NSFetchedResultsController {
		get {
			return MailboxObserversManager.sharedInstance.fetchedResultsControllerForType(mailboxType ?? .Inbox)
		}
	}
	
	var fetchedObjects: [Message]{
		get {
			return fetchedResultsController.fetchedObjects as? [Message] ?? [Message]()
		}
	}
	
	var fetchedObjectsThread: [Thread]{
		get {
			return fetchedResultsController.fetchedObjects as? [Thread] ?? [Thread]()
		}
	}
	
	var mailboxType: MailboxType = .Inbox {
		didSet{
			self.navigationItem.title = mailboxType.rawValue.firstCapitalized ?? "Mailbox"
		}
	}
	
	var messageForSegue: Message?
	
	@IBOutlet weak var tableView: UITableView!
	
	var lastupdatedLabel: UILabel?
	var newEmailsLabel: UILabel?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.registerNib(UINib(nibName: "MessageTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "mailCell")
		tableView.tableFooterView = UIView()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetSource = self
		
		MailboxObserversManager.sharedInstance.addObserverForMailboxType(mailboxType ?? .Inbox, observer: self)
		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(mailboxType ?? .Inbox, observer: self)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Hamburger_Icon"), style: UIBarButtonItemStyle.Plain, target: self, action: "showSideMenu:")
		
	}
	
	func showSideMenu(sender: UIBarButtonItem) {
		presentLeftMenuViewController()
	}
	
	func replyToMessage(notification: NSNotification) {
		
		if let message = notification.object {
			if message is Message {
				let replyNC = (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MessageComposeNavigationController") as! GradientNavigationController)
				let replyVC = replyNC.viewControllers.first as! MessageComposeTableViewController
				replyVC.messageToReplyTo = message as? Message
				self.presentViewController(replyNC, animated: true, completion: nil)
			}
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath) as! MessageTableViewCell
		if mailboxType == .Unread {
			
			if indexPath.row < fetchedObjectsThread.count {
				if let data = fetchedObjectsThread[indexPath.row].mostRecentMessage {
					FormattingPluginProvider.messageCellPluginForInboxType(.Unread)?.populateView(data: data, view: cell)
				}
			}
			
		} else {
			
			FormattingPluginProvider.messageCellPluginForInboxType(mailboxType)?.populateView(data: fetchedObjects[indexPath.row], view: cell)
		}
		cell.delegate = self
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		for cell in tableView.visibleCells {
			if let cell = cell as? SWTableViewCell {
				cell.hideUtilityButtonsAnimated(true)
			}
		}
		
		let isUnreadBox = mailboxType == .Unread
		let count = isUnreadBox ? fetchedObjectsThread.count : fetchedObjects.count
		
		
		if indexPath.row < count {
			
			let message = isUnreadBox ? fetchedObjectsThread[indexPath.row].messages?.anyObject() as! Message: fetchedObjects[indexPath.row]
			messageForSegue = message
			
			if mailboxType == .Drafts {
				performSegueWithIdentifier("showMessageComposeNavigationController", sender: self)
			} else if let _ = message.thread {
				performSegueWithIdentifier("showThreadTableViewController", sender: self)
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
		if let path = tableView.indexPathForCell(cell) where path.row < fetchedObjects.count {
			let data = fetchedObjects[path.row]
			ActionPluginProvider.messageCellPluginForInboxType(mailboxType)?.leftButtonTriggered(index, data: data, callback: nil)
		}
	}
	
	func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
		if let path = tableView.indexPathForCell(cell) where path.row < fetchedObjects.count {
			let data = fetchedObjects[path.row]
			ActionPluginProvider.messageCellPluginForInboxType(mailboxType)?.rightButtonTriggered(index, data: data, callback: nil)
		}
	}
	
	func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
		return true
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
			
			if (mailboxType == .Unread) {
				if let destination = segue.destinationViewController as? ThreadTableViewController {
					destination.primaryMessage = self.messageForSegue!.thread?.oldestUnreadMessage
				}
			}
		} else if segue.identifier == "showMessageComposeNavigationController" {
			let dc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! MessageComposeTableViewController
			dc.draftMessage = self.messageForSegue
		}
	}
	
	// MARK: Empty Dataset DataSource
	
	func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
		return UIImage(named: "Inbox_Zero_Graphic_1")
	}
	
	func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
		let style = NSMutableParagraphStyle()
		style.alignment = .Center
		return NSAttributedString(string: "Don't forget to reach out to\nold friends you played with.", attributes: [NSForegroundColorAttributeName: UIColor.grayColor(), NSFontAttributeName: UIFont.systemFontOfSize(14), NSParagraphStyleAttributeName: style])
	}
	
}
