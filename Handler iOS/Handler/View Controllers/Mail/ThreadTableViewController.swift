//
//  ThreadTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 24/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class ThreadTableViewController: UITableViewController, SWTableViewCellDelegate {
    
    enum CellType: Int {
        case Connector = 0
        case Sender = 1
        case Content = 2
    }
    
    var thread: Thread? {
        didSet {
            primaryMessage = orderedMessages.first
        }
    }
    var messageForSegue: Message?
    var primaryMessage: Message? {
        didSet(previous) {
            var scrollIndex: NSIndexPath?
            var pathsToReload = [NSIndexPath]()
            if let previous = previous {
                let oldindex = orderedMessages.indexOf(previous)! * 3
                for i in oldindex...oldindex+2 {
                    print(i)
                    pathsToReload.append(NSIndexPath(forRow: i, inSection: 0))
                }
            }
            if let primaryMessage = primaryMessage {
                let newindex = orderedMessages.indexOf(primaryMessage)! * 3
                for i in newindex...newindex+2 {
                    pathsToReload.append(NSIndexPath(forRow: i, inSection: 0))
                }
                scrollIndex = NSIndexPath(forRow: newindex, inSection: 0)
            }
            
            tableView.reloadRowsAtIndexPaths(pathsToReload, withRowAnimation: UITableViewRowAnimation.Automatic)
            if let index = scrollIndex {
                tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Top, animated: true)
            }
        }
    }
    
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
    
    func messageForIndexPath(indexPath: NSIndexPath)->Message{
        return orderedMessages[Int(floor(Float(indexPath.row / 3)))]
    }
    
    func cellTypeForIndexPath(indexPath: NSIndexPath)->CellType{
        return CellType(rawValue: Int(indexPath.row % 3))!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedMessages.count * 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var bgColor: UIColor?
        
        let message = messageForIndexPath(indexPath)
        if message == primaryMessage {
            bgColor = UIColor.whiteColor()
        }else{
            bgColor = UIColor.blueGrayBackgroundColor()
        }
        
        switch cellTypeForIndexPath(indexPath){
        case .Connector:
            let cell = tableView.dequeueReusableCellWithIdentifier("messageConnectionCell", forIndexPath: indexPath)
            cell.contentView.backgroundColor = bgColor
            return cell
        case .Content:
            let cell = tableView.dequeueReusableCellWithIdentifier("messageContentCell", forIndexPath: indexPath) as! MessageContentTableViewCell
            cell.contentView.backgroundColor = bgColor
            FormattingPluginProvider.messageContentCellPluginForConversation()?.populateView(data: message, view: cell)
            return cell
        case .Sender:
            let cell = tableView.dequeueReusableCellWithIdentifier("messageSenderCell", forIndexPath: indexPath) as! MessageSenderTableViewCell
            cell.contentView.backgroundColor = bgColor
            FormattingPluginProvider.messageContentCellPluginForConversation()?.populateView(data: message, view: cell)
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
        bottomView.frame = CGRectMake(0, view.frame.height-0.5, view.frame.width, 0.5)
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
        if indexPath.row == 0 {
            return 0
        }
        
        if let primaryMessage = primaryMessage {
            let newindex = orderedMessages.indexOf(primaryMessage)! * 3
            if indexPath.row == newindex {
                return 0
            }
        }
        
        if indexPath.row % 3 == 0 {
            return 45
        } else if indexPath.row % 3 == 1 {
            return 86
            
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        primaryMessage = messageForIndexPath(indexPath)
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        return true
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        if let path = tableView.indexPathForCell(cell) where path.row/2 < orderedMessages.count {
            let data = orderedMessages[Int(floor(Float(path.row / 2)))]
            ActionPluginProvider.messageCellPluginForInboxType(.Inbox)?.leftButtonTriggered(index, data: data, callback: nil)
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        if let path = tableView.indexPathForCell(cell) where path.row/2 < orderedMessages.count {
            let data = orderedMessages[Int(floor(Float(path.row / 2)))]
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
