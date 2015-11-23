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
        tableView.registerNib(UINib(nibName: "MessageTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "mailCell")
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		for cell in tableView.visibleCells {
			FormattingPluginProvider.messageCellPluginForInboxType(.Inbox)?.populateView(data: orderedMessages[tableView.indexPathForCell(cell)!.row], view: cell as! MessageTableViewCell)
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
            FormattingPluginProvider.messageCellPluginForInboxType(.Inbox)?.populateView(data: orderedMessages[indexPath.row], view: cell)
		}
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
        if let path = tableView.indexPathForCell(cell) where path.row < orderedMessages.count {
            let data = orderedMessages[path.row]
            ActionPluginProvider.messageCellPluginForInboxType(.Inbox)?.leftButtonTriggered(index, data: data, callback: nil)
        }
    }
	
	func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        if let path = tableView.indexPathForCell(cell) where path.row < orderedMessages.count {
            let data = orderedMessages[path.row]
            ActionPluginProvider.messageCellPluginForInboxType(.Inbox)?.rightButtonTriggered(index, data: data, callback: nil)
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
		}
	}
}
