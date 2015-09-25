//
//  ThreadTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 24/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class ThreadTableViewController: UITableViewController, SWTableViewCellDelegate {
	
	var thread: Thread?
	var messageForSegue: Message?
	
	var orderedMessages: [Message] {
		if let thread = thread, let msg = thread.messages?.allObjects as? [Message] {
			return msg.sort({ (item1, item2) -> Bool in
				if let firstDate = item1.sent_at, let secondDate = item2.sent_at {
					return firstDate.compare(secondDate) == NSComparisonResult.OrderedDescending
				}else{
					return true
				}
			})
		}else{
			return [Message]()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(animated: Bool) {
		for cell in tableView.visibleCells {
			(cell as? MessageTableViewCell)?.refreshFlags()
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return orderedMessages.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath) as! MessageTableViewCell
		if indexPath.row < orderedMessages.count {
			cell.message = orderedMessages[indexPath.row]
		}
		cell.leftUtilityButtons = cell.leftButtons()
		cell.rightUtilityButtons = cell.rightButtons()
		cell.delegate = self
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row < orderedMessages.count {
			messageForSegue = orderedMessages[indexPath.row]
			performSegueWithIdentifier("showMessageDetailViewController", sender: self)
		}
	}
	
	func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
		return true
	}
	
	func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
		if let cell = cell as? MessageTableViewCell, let message = cell.message {
			message.addLabelWithID("UNREAD")
			cell.message = message
		}
	}
	
	func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
		if let cell = cell as? MessageTableViewCell, let message = cell.message {
			switch index {
			case 0:
				// More
				break;
			case 1:
				// Flag
				message.addLabelWithID("FLAGGED")
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
		}
	}
}
