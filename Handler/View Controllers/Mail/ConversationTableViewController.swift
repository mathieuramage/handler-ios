//
//  ConversationTableViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 08/09/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class ConversationTableViewController: UITableViewController {
	
	let MessageCellID = "ConversationMessageTableViewCell"

	var conversation : Conversation?

	var allConversations : [Conversation]?

	var previousConversation : Conversation? {
		get {
			guard let conversations = allConversations, let index = allConversations?.indexOf(conversation!) where index > 0 else {
				return nil
			}
			return conversations[index - 1]
		}
	}

	var nextConversation : Conversation? {
		get {
			guard let conversations = allConversations, let index = allConversations?.indexOf(conversation!) where index < conversations.count - 1 else {
				return nil
			}
			return conversations[index + 1]
		}
	}

	var plugin: BottomBarActionPlugin! //Need to update this, way too complicated.

	var primaryMessage: Message? {
		didSet(previous) {
			if primaryMessage != previous {

				// OTTODO: Suppor primary message
//				guard let primaryMessage = primaryMessage, newIndex = conversation?.messages.indexOf(primaryMessage) else {
//					return
//				}
//
//				guard let previous = previous, previousIndex = conversation?.messages.indexOf(previous) else {
//					return
//				}
//
//				let scrollIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
//				let previousIndexPath = NSIndexPath(forRow: previousIndex, inSection: 0)
//				let indexesToReload = [scrollIndexPath, previousIndexPath]
//
//				tableView.reloadRowsAtIndexPaths(indexesToReload, withRowAnimation: .Automatic)
//				tableView.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition: .Top, animated: true)
			}
		}
	}

	var _sizingCell: ConversationMessageTableViewCell?
	var sizingCell: ConversationMessageTableViewCell {
		get {
			if _sizingCell == nil {
				_sizingCell = self.tableView.dequeueReusableCellWithIdentifier(MessageCellID) as? ConversationMessageTableViewCell
			}

			return _sizingCell!
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let messageNib = UINib(nibName: "ConversationMessageTableViewCell", bundle: nil);
		tableView.registerNib(messageNib, forCellReuseIdentifier: MessageCellID)
		tableView.backgroundColor = UIColor(rgba: HexCodes.offWhite)
		tableView.tableFooterView = UIView()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.plugin = BottomBarActionPluginProvider.plugin(self)
//		self.navigationController!.toolbar!.items = plugin.barButtonItemsForThread(thread)
	}

	// MARK: UITableViewDataSource

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return conversation?.messages?.count ?? 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(MessageCellID, forIndexPath: indexPath) as! ConversationMessageTableViewCell
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
//		label.text = orderedMessages.last?.subject ?? "No Subject"
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

		// This is needed due the internal implementation of RichTextEditor being loaded into a webview and thus the height might not be available right way.
		var loopUntil = NSDate(timeIntervalSinceNow: 0.05)
		let timeOut = NSDate(timeIntervalSinceNow:2)
		while (!sizingCell.isCellReady() && NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: loopUntil)) {
			if NSDate().timeIntervalSinceReferenceDate >= timeOut.timeIntervalSinceReferenceDate {
				return 200
			}

			loopUntil = NSDate(timeIntervalSinceNow: 0.05)
		}

		return sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
	}

	override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return self.tableView(tableView, heightForRowAtIndexPath: indexPath)
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		primaryMessage = conversation!.orderedMessages()[indexPath.row]
	}

	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

		let message = conversation!.orderedMessages()[indexPath.row]
		if !message.read {
			MessageOperations.setMessageAsRead(message: message, read: true, callback: nil)
		}
	}

	func configureCell(cell: ConversationMessageTableViewCell, indexPath: NSIndexPath) {
		let message = conversation!.orderedMessages()[indexPath.row]

		let lastMessage = indexPath.row + 1 >= conversation!.orderedMessages().count
		let primary = message == primaryMessage
		configureDotColorForCell(cell, indexPath: indexPath)
//		FormattingPluginProvider.messageContentCellPluginForConversation()?.populateView(data: message, view: cell, lastMessage: lastMessage, primary: primary)
		ConversationTableViewCellHelper.configureCell(cell, message: message, lastMessage: lastMessage, primary: primary)
	}

	func configureDotColorForCell(cell: ConversationMessageTableViewCell, indexPath: NSIndexPath) {
		let message = conversation!.orderedMessages()[indexPath.row]

		if message.starred == true {
			cell.dotImageView.image = UIImage(named: "Orange_Dot")
		} else if !message.read {
			cell.dotImageView.image = UIImage(named: "Blue_Dot")
		} else {
			cell.dotImageView.image = nil
		}
	}

	func reloadCellForMessage(message : Message) {
		if let index = conversation!.orderedMessages().indexOf(message) {
			let indexPath = NSIndexPath(forRow: index, inSection: 0)
			let cell = tableView.cellForRowAtIndexPath(indexPath) as! ConversationMessageTableViewCell
			configureDotColorForCell(cell,indexPath: indexPath)
			tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
		}
	}
}
