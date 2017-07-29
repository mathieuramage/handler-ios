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
	
	let EmailActionsEvents = AppEvents.EmailActions.self
	
	var conversation : Conversation?
	
	var allConversations : [Conversation]?
	
	var previousConversation : Conversation? {
		get {
			guard let conversations = allConversations, let index = allConversations?.index(of: conversation!), index > 0 else {
				return nil
			}
			return conversations[index - 1]
		}
	}
	
	var nextConversation : Conversation? {
		get {
			guard let conversations = allConversations, let index = allConversations?.index(of: conversation!), index < conversations.count - 1 else {
				return nil
			}
			return conversations[index + 1]
		}
	}
	
	var plugin: BottomBarActionPlugin! //Need to update this, way too complicated.
	
	var primaryMessage: Message? {
		didSet(previous) {
			if primaryMessage != previous {
				
				guard let primaryMessage = primaryMessage, let newIndex = conversation?.orderedMessagesByCreationTime().index(of: primaryMessage) else {
					return
				}
				
				guard let previous = previous, let previousIndex = conversation?.orderedMessagesByCreationTime().index(of: previous) else {
					return
				}
				
				let scrollIndexPath = IndexPath(row: newIndex, section: 0)
				let previousIndexPath = IndexPath(row: previousIndex, section: 0)
				let indexesToReload = [scrollIndexPath, previousIndexPath]
				
				tableView.reloadRows(at: indexesToReload, with: .automatic)
				tableView.scrollToRow(at: scrollIndexPath, at: .top, animated: true)
			}
		}
	}
	
	var _sizingCell: ConversationMessageTableViewCell?
	var sizingCell: ConversationMessageTableViewCell {
		get {
			if _sizingCell == nil {
				_sizingCell = self.tableView.dequeueReusableCell(withIdentifier: MessageCellID) as? ConversationMessageTableViewCell
			}
			
			return _sizingCell!
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let messageNib = UINib(nibName: "ConversationMessageTableViewCell", bundle: nil);
		tableView.register(messageNib, forCellReuseIdentifier: MessageCellID)
		tableView.backgroundColor = UIColor(rgba: HexCodes.offWhite)
		tableView.tableFooterView = UIView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.plugin = BottomBarActionPluginProvider.plugin(self)
		
		AppAnalytics.fireContentViewEvent(contentId: EmailActionsEvents.read, event: EmailActionsEvents)
		self.navigationController!.toolbar!.items = plugin.barButtonItemsForThread(conversation)
	}
	
	// MARK: UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return conversation?.messages?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: MessageCellID, for: indexPath) as! ConversationMessageTableViewCell
		configureCell(cell, indexPath: indexPath)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.white
		let height = self.tableView(tableView, heightForHeaderInSection: section)
		let width = tableView.bounds.width
		view.frame = CGRect(x: 0, y: 0, width: width, height: height)
		let label = UILabel()
		label.backgroundColor = UIColor.clear
		label.textColor = UIColor(rgba: HexCodes.darkGray)
		label.font = UIFont.systemFont(ofSize: 15)
		label.frame = view.bounds.insetBy(dx: 12, dy: 10)
		label.clipsToBounds = false
		view.addSubview(label)
		label.text = conversation?.orderedMessagesByCreationTime().last?.subject ?? "No Subject"
		let bottomView = UIView()
		bottomView.frame = CGRect(x: 0, y: view.frame.height-0.5, width: view.frame.width, height: 0.5)
		bottomView.backgroundColor = UIColor(rgba: HexCodes.lightGray)
		bottomView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleBottomMargin]
		bottomView.translatesAutoresizingMaskIntoConstraints = true
		view.addSubview(bottomView)
		return view
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 45
	}
	
	// Note: We could use UITableViewAutomaticDimension here however this make the animation really weird on first run
	// This old school code makes things way smoother.
	// TODO: Check with a time profiler if this code is slow
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		configureCell(sizingCell, indexPath: indexPath)
		
		// This is needed due the internal implementation of RichTextEditor being loaded into a webview and thus the height might not be available right way.
		var loopUntil = Date(timeIntervalSinceNow: 0.05)
		let timeOut = Date(timeIntervalSinceNow:2)
		while (!sizingCell.isCellReady() && RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: loopUntil)) {
			if Date().timeIntervalSinceReferenceDate >= timeOut.timeIntervalSinceReferenceDate {
				return 200
			}
			
			loopUntil = Date(timeIntervalSinceNow: 0.05)
		}
		
		return sizingCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
	}
	
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		primaryMessage = conversation!.orderedMessagesByCreationTime()[indexPath.row]
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let message = conversation!.orderedMessagesByCreationTime()[indexPath.row]
		if !message.read {
			MessageOperations.setMessageAsRead(message: message, read: true, callback: nil)
		}
	}
	
	func configureCell(_ cell: ConversationMessageTableViewCell, indexPath: IndexPath) {
		let message = conversation!.orderedMessagesByCreationTime()[indexPath.row]
		
		let lastMessage = indexPath.row + 1 >= conversation!.orderedMessagesByCreationTime().count
		let primary = message == primaryMessage
		configureDotColorForCell(cell, indexPath: indexPath)
		//		FormattingPluginProvider.messageContentCellPluginForConversation()?.populateView(data: message, view: cell, lastMessage: lastMessage, primary: primary)
		ConversationTableViewCellHelper.configureCell(cell, message: message, lastMessage: lastMessage, primary: primary)
	}
	
	func configureDotColorForCell(_ cell: ConversationMessageTableViewCell, indexPath: IndexPath) {
		let message = conversation!.orderedMessagesByCreationTime()[indexPath.row]
		
		if message.starred == true {
			cell.dotImageView.image = UIImage(named: "Orange_Dot")
		} else if !message.read {
			cell.dotImageView.image = UIImage(named: "Blue_Dot")
		} else {
			cell.dotImageView.image = nil
		}
	}
	
	func reloadCellForMessage(_ message : Message) {
		if let index = conversation!.orderedMessagesByCreationTime().index(of: message) {
			let indexPath = IndexPath(row: index, section: 0)
			let cell = tableView.cellForRow(at: indexPath) as! ConversationMessageTableViewCell
			configureDotColorForCell(cell,indexPath: indexPath)
			tableView.reloadRows(at: [indexPath], with: .none)
		}
	}
}
