//
//  ThreadTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 24/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class ThreadTableViewController: UITableViewController {
    
    let MessageCellID = "MessageCellID"
    
    var thread: Thread? {
        didSet {
            if let allMessages = thread?.messages?.allObjects as? [Message] {
                orderedMessages = allMessages.sort({ (item1, item2) -> Bool in
                    if let firstDate = item1.sent_at, let secondDate = item2.sent_at {
                        return firstDate.compare(secondDate) == NSComparisonResult.OrderedDescending
                    }
                    else {
                        return true
                    }
                })
            }
            else {
                orderedMessages = [Message]()
            }
            
            primaryMessage = orderedMessages.first
            
            tableView.reloadData()
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
    
    var primaryMessage: Message? {
        didSet(previous) {
            if primaryMessage != previous {
                guard let primaryMessage = primaryMessage, newIndex = orderedMessages.indexOf(primaryMessage) else {
                    return
                }
                
                guard let previous = previous, previousIndex = orderedMessages.indexOf(previous) else {
                    return
                }
                
                let scrollIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                let previousIndexPath = NSIndexPath(forRow: previousIndex, inSection: 0)
                let indexesToReload = [scrollIndexPath, previousIndexPath]
                
                tableView.reloadRowsAtIndexPaths(indexesToReload, withRowAnimation: .Automatic)
                tableView.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition: .Top, animated: true)
            }
        }
    }
    
    var orderedMessages = [Message]()
    
    var _sizingCell: ThreadMessageTableViewCell?
    var sizingCell: ThreadMessageTableViewCell {
        get {
            if _sizingCell == nil {
                _sizingCell = self.tableView.dequeueReusableCellWithIdentifier(MessageCellID) as? ThreadMessageTableViewCell
            }
            
            return _sizingCell!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let messageNib = UINib(nibName: "ThreadMessageTableViewCell", bundle: nil);
        tableView.registerNib(messageNib, forCellReuseIdentifier: MessageCellID)
        tableView.backgroundColor = UIColor(rgba: HexCodes.offWhite)
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.plugin = BottomBarActionPluginProvider.plugin(self)
        self.navigationController!.toolbar!.items = plugin.barButtonItemsForThread(thread)
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedMessages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MessageCellID, forIndexPath: indexPath) as! ThreadMessageTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
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
    
    // Note: We could use UITableViewAutomaticDimension here however this make the animation really weird on first run
    // This old school code makes things way smoother.
    // TODO: Check with a time profiler if this code is slow
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        configureCell(sizingCell, indexPath: indexPath)
        
        return sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        primaryMessage = orderedMessages[indexPath.row]
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let message = orderedMessages[indexPath.row]
        if message.isUnread {
            message.markAsRead()
        }
    }
    
    func configureCell(cell: ThreadMessageTableViewCell, indexPath: NSIndexPath) {
        let message = orderedMessages[indexPath.row]
        
        let lastMessage = indexPath.row + 1 >= orderedMessages.count
        let primary = message == primaryMessage
        FormattingPluginProvider.messageContentCellPluginForConversation()?.populateView(data: message, view: cell, lastMessage: lastMessage, primary: primary)
    }
}
