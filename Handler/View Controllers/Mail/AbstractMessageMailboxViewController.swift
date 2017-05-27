//
//  AbstractMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class AbstractMessageMailboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, SWTableViewCellDelegate, /*MailboxCountObserver, */ DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
	
	static let mailboxNeedsUpdate = Notification.Name("MailboxNeedsUpdate")
	
	var sideMenuVC: SideMenuViewController!
	var fetchedResultsController: NSFetchedResultsController<Message>!
	var fetchedObjects: [Message] {return fetchedResultsController.fetchedObjects ?? [Message]()}
	
	var mailboxType: MailboxType = .Inbox {
		didSet{
			self.navigationItem.title = mailboxType == .Flagged ? "Flagged" : mailboxType.rawValue.firstCapitalized
		}
	}
	
	var messageForSegue: Message?
	
	@IBOutlet weak var tableView: UITableView!
	
	var lastupdatedLabel: UILabel?
	var newEmailsLabel: UILabel?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register(UINib(nibName: "MessageTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MessageTableViewCell")
		tableView.tableFooterView = UIView()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetSource = self
		fetchedResultsController.delegate = self
		if let menuVC = sideMenuViewController?.leftMenuViewController as? SideMenuViewController {
			sideMenuVC = menuVC
		}
		NotificationCenter.default.addObserver(self, selector: #selector(refresh), name:
			AbstractMessageMailboxViewController.mailboxNeedsUpdate, object: nil)
		//		MailboxObserversManager.sharedInstance.addObserverForMailboxType(mailboxType , observer: self)
		//		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(mailboxType , observer: self)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		try? fetchedResultsController.performFetch()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Hamburger_Icon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AbstractMessageMailboxViewController.showSideMenu(_:)))
		fireAnalyticsEvents()
	}
	
	func fireAnalyticsEvents() {
		switch mailboxType {
		case .Inbox:
			AppAnalytics.fireContentViewEvent(contentId: AppEvents.Mailbox.inbox, event: AppEvents.Mailbox.self)
			break
		case .Unread:
			AppAnalytics.fireContentViewEvent(contentId: AppEvents.Mailbox.unread, event: AppEvents.Mailbox.self)
			break
		case .Flagged:
			AppAnalytics.fireContentViewEvent(contentId: AppEvents.Mailbox.flagged, event: AppEvents.Mailbox.self)
			break
		case .Drafts:
			AppAnalytics.fireContentViewEvent(contentId: AppEvents.Mailbox.drafts, event: AppEvents.Mailbox.self)
			break
		case .Sent:
			AppAnalytics.fireContentViewEvent(contentId: AppEvents.Mailbox.sent, event: AppEvents.Mailbox.self)
			break
		case .Archive:
			AppAnalytics.fireContentViewEvent(contentId: AppEvents.Mailbox.archive, event: AppEvents.Mailbox.self)
			break
		case .AllChanges:
			break
		}
	}
	
	func refresh() {
		ConversationOperations.getAllConversations(before: Date(), after: nil, limit: 0) { (success, conversations) in
			//            self.refreshControl?.endRefreshing()
			self.sideMenuVC.optionsTableViewController?.mailboxCountDidChange(self.mailboxType, newCount: self.fetchedObjects.count)
		}
	}
	
	func showSideMenu(_ sender: UIBarButtonItem) {
		presentLeftMenuViewController()
	}
	
	func replyToMessage(_ notification: Notification) {
		
		if let message = notification.object {
			if message is Message {
				let replyNC = Storyboards.Main.instantiateViewController(withIdentifier: "MessageComposeNavigationController") as! GradientNavigationController
				let replyVC = replyNC.viewControllers.first as! MessageComposeTableViewController
				replyVC.messageToReplyTo = message as? Message
				self.present(replyNC, animated: true, completion: nil)
			}
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
		if mailboxType == .Unread {
			//			if indexPath.row < fetchedObjectsThread.count {
			//				let conversation = fetchedObjectsThread[indexPath.row]
			//				InboxMessageTableViewCellHelper.configureCell(cell, conversation: conversation)
			//			}
		} else {
			FormattingPluginProvider.messageCellPluginForInboxType(mailboxType)?.populateView(data: fetchedObjects[indexPath.row], view: cell)
		}
		cell.delegate = self
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		for cell in tableView.visibleCells {
			if let cell = cell as? SWTableViewCell {
				cell.hideUtilityButtons(animated: true)
			}
		}
		
		let count = fetchedObjects.count
		
		if indexPath.row < count {
			let message = fetchedObjects[indexPath.row]
			
			messageForSegue = message
			
			if mailboxType == .Drafts {
				performSegue(withIdentifier: "showMessageComposeNavigationController", sender: self)
			} else if let _ = message.conversation {
				performSegue(withIdentifier: "showConversationTableViewController", sender: self)
			}
		}
	}
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.tableView.endUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case NSFetchedResultsChangeType.insert:
			self.tableView.insertSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.fade)
		case NSFetchedResultsChangeType.delete:
			self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.fade)
		default:
			break;
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case NSFetchedResultsChangeType.insert:
			self.tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
		case NSFetchedResultsChangeType.delete:
			self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
		case NSFetchedResultsChangeType.update:
			self.tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
		case NSFetchedResultsChangeType.move:
			self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
		}
	}
	
	func mailboxCountDidChange(_ mailboxType: MailboxType, newCount: Int) {
		if mailboxType == MailboxType.Unread {
			newEmailsLabel?.text = "\(newCount) unread emails"
		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
	
	func swipeableTableViewCell(_ cell: SWTableViewCell!, canSwipeTo state: SWCellState) -> Bool {
		return true
	}
	
	func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerLeftUtilityButtonWith index: Int) {
		
		if mailboxType == .Unread {
			//			if let path = tableView.indexPath(for: cell), path.row < fetchedObjectsThread.count, let data = fetchedObjectsThread[path.row].mostRecentMessage {
			//				ActionPluginProvider.messageCellPluginForInboxType(.Inbox)?.leftButtonTriggered(index, data: data, callback: nil)
			//			}
		} else {
			
			if let path = tableView.indexPath(for: cell), path.row < fetchedObjects.count {
				let data = fetchedObjects[path.row]
				ActionPluginProvider.messageCellPluginForInboxType(mailboxType)?.leftButtonTriggered(index, data: data, callback: nil)
			}
		}
	}
	
	func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
		if let path = tableView.indexPath(for: cell), path.row < fetchedObjects.count {
			let data = fetchedObjects[path.row]
			ActionPluginProvider.messageCellPluginForInboxType(mailboxType)?.rightButtonTriggered(index, data: data, callback: nil)
		}
	}
	
	func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
		return true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		if segue.identifier == "showConversationTableViewController" {
			let dc = segue.destination as! ConversationTableViewController
			dc.conversation = self.messageForSegue?.conversation
			var threads = [Conversation]()
			for message in self.fetchedObjects {
				if let thread = message.conversation {
					threads.append(thread)
				}
			}
			dc.allConversations = threads
			
			if (mailboxType == .Unread) {
				if let destination = segue.destination as? ConversationTableViewController {
					destination.primaryMessage = self.messageForSegue!.conversation?.oldestUnreadMessage
				}
			}
		} else if segue.identifier == "showMessageComposeNavigationController" {
			if let dc = (segue.destination as? UINavigationController)?.viewControllers.first as? MessageComposerWrapperViewController {
				dc.draftMessage = self.messageForSegue
			}
		}
	}
	
	// MARK: Empty Dataset DataSource
	func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
		return UIImage(named: "Inbox_Zero_Graphic_1")
	}
	
	func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let style = NSMutableParagraphStyle()
		style.alignment = .center
		return NSAttributedString(string: "Don't forget to reach out to\nold friends you played with.", attributes: [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSParagraphStyleAttributeName: style])
	}
	
	func composeNewMessage() {
		self.performSegue(withIdentifier: "showMessageComposeNavigationController", sender: self)
	}
	
}
