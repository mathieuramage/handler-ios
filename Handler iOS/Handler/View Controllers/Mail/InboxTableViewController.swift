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
import Bond

class InboxTableViewController: UITableViewController, SWTableViewCellDelegate, NSFetchedResultsControllerDelegate {
	
	var threadForSegue: Thread?
	
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
		tableView.tableFooterView = UIView()
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl!)
		MailboxObserversManager.sharedInstance.addObserverForMailboxType(.Inbox, observer: self)
	}
	
	func refresh(control: UIRefreshControl){
		APICommunicator.sharedInstance.fetchNewMessagseWithCompletion { (error) -> Void in
			control.endRefreshing()
			guard let error = error else {
				return
			}
			Async.main(block: { () -> Void in
				var errorPopup = ErrorPopupViewController()
				errorPopup.error = error
				errorPopup.show()
			})
		}
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
		
		let composeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "composeNewMessage:")
		
		self.navigationController!.toolbar.items = [space, item, space, composeItem]
		
		let navigationbarFrame = self.navigationController!.navigationBar.bounds
		navigationController?.navigationBar.clipsToBounds = false
		progressBar = UIProgressView(frame: CGRectMake(0, navigationbarFrame.height - 2.5, navigationbarFrame.width, 2.5))
		progressBar.progressViewStyle = .Bar
		progressBar.progressTintColor = UIColor.whiteColor()
		progressBar.hidden = true
		
		CurrentStatusManager.sharedInstance.currentUploadProgress.observe { progress in
			self.progressBar.progress = progress
			self.progressBar.hidden = progress == 0 || progress == 1
		}
		
		self.navigationController?.navigationBar.addSubview(progressBar)
		if let cells = self.tableView.visibleCells as? [MessageTableViewCell]{
			for cell in cells {
				cell.refreshFlags()
			}
		}
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
		for cell in tableView.visibleCells {
			if let cell = cell as? SWTableViewCell {
				cell.hideUtilityButtonsAnimated(true)
			}
		}
		if indexPath.row < fetchedObjects.count {
			navigationItem.rightBarButtonItem?.enabled = false
			
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
