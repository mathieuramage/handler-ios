//
//  ThreadTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 24/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//b

import UIKit

class ThreadTableViewController: UITableViewController, SWTableViewCellDelegate {
    
    enum CellType: Int {
        case Connector = 0
        case Sender = 1
        case Content = 2
    }
    
    var thread: Thread? {
        didSet {
            tableView.reloadData()
            primaryMessage = nil
            primaryMessage = orderedMessages.first
        }
    }
    var allThreads: [Thread] = [Thread]()
    var nextThread: Thread? {
        if let thread = thread, let indexOfCurrent = allThreads.indexOf(thread) {
            if allThreads.count > indexOfCurrent + 1 {
                return allThreads[indexOfCurrent + 1]
            }
        }
        return nil
    }
    var plugin: BottomBarActionPlugin!
    var previousThread: Thread? {
        if let thread = thread, let indexOfCurrent = allThreads.indexOf(thread) {
            if indexOfCurrent >= 1 && indexOfCurrent < allThreads.count {
                return allThreads[indexOfCurrent - 1]
            }
        }
        return nil
    }
    var messageForSegue: Message?
    var primaryMessage: Message? {
        didSet(previous) {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)

            return /* DISABLES CODE */
            if primaryMessage != previous {
                var scrollIndex: NSIndexPath?
                var pathsToReload = [NSIndexPath]()
                if let previous = previous {
                    if var oldindex = orderedMessages.indexOf(previous) {
                        oldindex *= 3
                        for i in oldindex...oldindex+2 {
                            pathsToReload.append(NSIndexPath(forRow: i, inSection: 0))
                        }
                    }
                }
                if let primaryMessage = primaryMessage {
                    if var newindex = orderedMessages.indexOf(primaryMessage) {
                        newindex *= 3
                    for i in newindex...newindex+2 {
                        pathsToReload.append(NSIndexPath(forRow: i, inSection: 0))
                    }
                        
                    scrollIndex = NSIndexPath(forRow: newindex, inSection: 0)
                    }
                }
                
                if pathsToReload.count == 0 {
                } else {
                    tableView.reloadRowsAtIndexPaths(pathsToReload, withRowAnimation: UITableViewRowAnimation.Automatic)
                    if let index = scrollIndex {
                        tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Top, animated: true)
                    }
                }
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
    
    func messageForIndexPath(indexPath: NSIndexPath)->Message?{
        let index = Int(floor(Float(indexPath.row / 3)))
        if index < orderedMessages.count {
            return orderedMessages[index]
        }else{
            return nil
        }
    }
    
    func cellTypeForIndexPath(indexPath: NSIndexPath)->CellType{
        
        if let message = messageForIndexPath(indexPath) {
        if let primaryMessage = primaryMessage where primaryMessage != message, let indexPrimary = orderedMessages.indexOf(primaryMessage), let indexSecondary = orderedMessages.indexOf(message) {
            if indexSecondary < indexPrimary {
                switch indexPath.row % 3 {
                case 0:
                    return CellType.Sender
                case 1:
                    return CellType.Content
                case 2:
                    return CellType.Connector
                default:
                    return CellType(rawValue: Int(indexPath.row % 3))!
                }
            }
            }
        }else{
            return CellType.Connector
        }
        
        
        return CellType(rawValue: Int(indexPath.row % 3))!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(rgba: HexCodes.offWhite)
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.plugin = BottomBarActionPluginProvider.plugin(self)
        self.navigationController!.toolbar!.items = plugin.barButtonItemsForThread(thread)
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
            bgColor = UIColor(rgba: HexCodes.offWhite)
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
        label.textColor = UIColor(rgba: HexCodes.darkGray)
        label.font = UIFont.systemFontOfSize(15)
        label.frame = CGRectInset(view.bounds, 12, 10)
        label.clipsToBounds = false
        view.addSubview(label)
        label.text = orderedMessages.last?.subject ?? "No Subject"
        
        let bottomView = UIView()
        bottomView.frame = CGRectMake(0, view.frame.height-0.5, view.frame.width, 0.5)
        bottomView.backgroundColor = UIColor(rgba: HexCodes.lightGray)
        bottomView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        bottomView.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(bottomView)
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if messageForIndexPath(indexPath) == primaryMessage && cellTypeForIndexPath(indexPath) == .Connector {
            return 0
        }
        
        switch cellTypeForIndexPath(indexPath){
        case .Connector:
            return 45
        case .Sender:
            return 86
        case .Content:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if cellTypeForIndexPath(indexPath) == .Sender {
            primaryMessage = messageForIndexPath(indexPath)
        }
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
}
