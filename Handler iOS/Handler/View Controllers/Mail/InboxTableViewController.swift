//
//  InboxTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData
import Async

class InboxTableViewController: UITableViewController, SWTableViewCellDelegate, MailboxCountObserver {
	
	var fetchedObjects: [Thread] = [Thread]() {
		didSet {
			self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
		}
	}
	
	var threadForSegue: Thread?
	
	var lastupdatedLabel: UILabel?
	var newEmailsLabel: UILabel?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl!)
		loadMessages()
		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(.Unread, observer: self)
		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(.AllChanges, observer: self)
	}
	
	func loadMessages() {
		MailDatabaseManager.sharedInstance.backgroundContext.performBlock { () -> Void in
			MailDatabaseManager.sharedInstance.saveBackgroundContext()
			let threads = try? MailDatabaseManager.sharedInstance.managedObjectContext.executeFetchRequest(Message.fetchRequestForMessagesWithInboxType(.Inbox))
			Async.main(block: { () -> Void in
				self.setThreads((threads as? [Thread]) ?? self.fetchedObjects)
			})
		}
	}
	
	func refresh(control: UIRefreshControl){
		APICommunicator.sharedInstance.fetchNewMessagseWithCompletion { (error) -> Void in
			control.endRefreshing()
			guard let error = error else {
				return
			}
			var errorPopup = ErrorPopupViewController()
			errorPopup.error = error
			errorPopup.show()
		}
	}
	
	func setThreads(newThreads: [Thread]){
		if newThreads != self.fetchedObjects {
			self.fetchedObjects = newThreads
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
		return fetchedObjects.count ?? 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath) as! MessageTableViewCell
		if indexPath.row < fetchedObjects.count {
			cell.message = fetchedObjects[indexPath.row].mostRecentMessage
		}else{
			cell.message = nil
		}
		cell.delegate = self
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row < fetchedObjects.count {
			let thread = fetchedObjects[indexPath.row]
			threadForSegue = thread
			if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MessageTableViewCell {
				cell.message = thread.mostRecentMessage
			}
			if let count = thread.messages?.count where count > 1 {
				performSegueWithIdentifier("showThreadTableViewController", sender: self)
			}else{
				performSegueWithIdentifier("showMessageDetailViewController", sender: self)
			}
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
		} else if mailboxType == .AllChanges {
			loadMessages()
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
			cell.hideUtilityButtonsAnimated(true)
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
				if !message.isArchived{
					message.moveToArchive()
				}
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
			dc.message = self.threadForSegue?.messages?.allObjects.first as? Message
		} else if segue.identifier == "showThreadTableViewController" {
			let dc = segue.destinationViewController as! ThreadTableViewController
			dc.thread = self.threadForSegue
		}
	}
}
