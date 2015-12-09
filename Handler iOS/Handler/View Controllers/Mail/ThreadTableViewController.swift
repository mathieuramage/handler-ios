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
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedMessages.count * 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("messageSenderCell", forIndexPath: indexPath) as! MessageSenderTableViewCell
            FormattingPluginProvider.messageContentCellPluginForConversation()?.populateView(data: orderedMessages[Int(floor(Float(indexPath.row / 2)))], view: cell)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("messageContentCell", forIndexPath: indexPath) as! MessageContentTableViewCell
            FormattingPluginProvider.messageContentCellPluginForConversation()?.populateView(data: orderedMessages[Int(floor(Float(indexPath.row / 2)))], view: cell)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let width = tableView.bounds.width
        view.frame = CGRectMake(0, 0, width, height)
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(15)
        label.frame = CGRectInset(view.bounds, 12, 15)
        view.addSubview(label)
        label.text = orderedMessages.last?.subject ?? "No Subject"
        
        let bottomView = UIView()
        bottomView.frame = CGRectMake(0, view.frame.height-1, view.frame.width, 1)
        bottomView.backgroundColor = UIColor.lightGrayColor()
        bottomView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        bottomView.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(bottomView)
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 86
        }else{
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 86
        }else{
            return UITableViewAutomaticDimension
        }
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
