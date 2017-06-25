//
//  InboxTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData
import Async
import DZNEmptyDataSet

class InboxTableViewController: UITableViewController, SWTableViewCellDelegate, NSFetchedResultsControllerDelegate, DZNEmptyDataSetSource {
	
	var conversationForSegue: Conversation?
	var activeConversation : Conversation?

	lazy var fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest: ConversationDao.inboxFetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
	var fetchedObjects: [Conversation] {
		return fetchedResultsController.fetchedObjects ?? [Conversation]()
	}

	var progressBar: UIProgressView!
	var lastupdatedLabel: UILabel?
	var unreadEmailsCountLabel: UILabel?
	var sideMenuVC: SideMenuViewController!
    var emptyView: EmptyInboxView? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UINib(nibName: "MessageTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MessageTableViewCell")
		tableView.tableFooterView = UIView()
		tableView.emptyDataSetSource = self
		self.refreshControl = UIRefreshControl()
		self.fetchedResultsController.delegate = self
		self.refreshControl!.addTarget(self, action: #selector(InboxTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
		self.tableView.addSubview(refreshControl!)
		MailboxObserversManager.sharedInstance.addObserverForMailboxType(.Inbox, observer: self)
		if let menuVC = sideMenuViewController?.leftMenuViewController as? SideMenuViewController {
			sideMenuVC = menuVC
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(conversationsUpdated), name:
			ConversationManager.conversationUpdateFinishedNotification, object: nil)
        do {
            try self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch {
            let fetchError = error as NSError
            print("fetcherror = \(fetchError), \(fetchError.userInfo)")
        }
	}
	
	func updateSideMenu() {
		self.sideMenuVC.optionsTableViewController?.mailboxCountDidChange(.Inbox, newCount: self.fetchedObjects.count)
	}
	
	func refreshInbox() {
		refresh()
	}
	
	func conversationsUpdated() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("fetcherror = \(fetchError), \(fetchError.userInfo)")
        }
        self.refreshControl?.endRefreshing()
		sideMenuVC.optionsTableViewController?.mailboxCountDidChange(.Inbox, newCount: fetchedObjects.count)
		tableView.reloadData()
        emptyView?.waitingView.isHidden = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		
		navigationItem.rightBarButtonItem?.isEnabled = true
		
		lastupdatedLabel = UILabel(frame: CGRect(x: 0, y: 8, width: 140, height: 14))
		lastupdatedLabel?.textAlignment = .center
		lastupdatedLabel?.font = UIFont.systemFont(ofSize: 11)
		lastupdatedLabel?.textColor = UIColor(rgba: HexCodes.darkGray)
		
//		_ = CurrentStatusManager.sharedInstance.currentStatus.observeNext { text in
//			Async.main {
//				self.lastupdatedLabel?.text = text
//			}
//		}
		
		unreadEmailsCountLabel = UILabel(frame: CGRect(x: 0, y: 26, width: 140, height: 10))
		unreadEmailsCountLabel?.textAlignment = .center
		unreadEmailsCountLabel?.font = UIFont.systemFont(ofSize: 11)
		unreadEmailsCountLabel?.textColor = UIColor(rgba: HexCodes.blueGray)
		
//		_ = CurrentStatusManager.sharedInstance.currentStatusSubtitle.observeNext { text in
//			Async.main {
//				self.unreadEmailsCountLabel?.text = text
//			}
//		}
		
		let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 44))
		containerView.addSubview(lastupdatedLabel!)
		containerView.addSubview(unreadEmailsCountLabel!)
		let item = UIBarButtonItem(customView: containerView)
		
		let composeItem = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.compose,
			target: self,
			action: #selector(InboxTableViewController.composeNewMessage))
		
		self.navigationController!.toolbar.items = [space, item, space, composeItem]
		
		let navigationbarFrame = self.navigationController!.navigationBar.bounds
		navigationController?.navigationBar.clipsToBounds = false
		progressBar = UIProgressView(frame: CGRect(x: 0, y: navigationbarFrame.height - 2.5, width: navigationbarFrame.width, height: 2.5))
		progressBar.progressViewStyle = .bar
		progressBar.progressTintColor = UIColor.white
		progressBar.isHidden = true
		
//		_ = CurrentStatusManager.sharedInstance.currentUploadProgress.observeNext { progress in
//			Async.main {
//				self.progressBar.progress = progress
//				self.progressBar.isHidden = progress == 0 || progress == 1
//			}
//		}
		
		self.navigationController?.navigationBar.addSubview(progressBar)
		
		if let cells = self.tableView.visibleCells as? [MessageTableViewCell] {
			for cell in cells {
				if let path = tableView.indexPath(for: cell), path.row < fetchedObjects.count {
					let conversation = fetchedObjects[path.row]
					InboxMessageTableViewCellHelper.configureCell(cell, conversation: conversation)
				}
			}
		}
	
		requestPushNotificationPermissions()
		showTitleFadeIn(title: "Inbox")
	    ConversationManager.updateConversations()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self)
		AppAnalytics.fireContentViewEvent(contentId: AppEvents.Mailbox.inbox, event: AppEvents.Mailbox.self)
        NotificationCenter.default.removeObserver(self, name:
            ConversationManager.conversationUpdateFinishedNotification, object: nil)
	}
	
	func refresh(_ control: UIRefreshControl) {
		refresh()
	}
	
	func refresh() {
		ConversationManager.updateConversations()
	}
	
	func requestPushNotificationPermissions() {
		let settings = UIUserNotificationSettings(types: [UIUserNotificationType.badge, UIUserNotificationType.sound,UIUserNotificationType.alert], categories: nil)
		UIApplication.shared.registerUserNotificationSettings(settings)
		UIApplication.shared.registerForRemoteNotifications()
		UIApplication.shared.applicationIconBadgeNumber = 0
	}
	
	func composeNewMessage() {
		performSegue(withIdentifier: "showMessageComposeNavigationController", sender: self)
	}
	
	@IBAction func showSideMenu(_ sender: UIBarButtonItem) {
		presentLeftMenuViewController()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedObjects.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
		
		if indexPath.row < fetchedObjects.count {
			let conversation = fetchedObjects[indexPath.row]
			InboxMessageTableViewCellHelper.configureCell(cell, conversation: conversation)
		}
		
		cell.delegate = self
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		for cell in tableView.visibleCells {
			if let cell = cell as? SWTableViewCell {
				cell.hideUtilityButtons(animated: true)
			}
		}
		if indexPath.row < fetchedObjects.count {
			navigationItem.rightBarButtonItem?.isEnabled = false
			activeConversation = fetchedObjects[indexPath.row]
			performSegue(withIdentifier: "showConversationTableViewController", sender: self)
		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
	
	// MARK: NSFetchedResultsController Delegate
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
			self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
		}
		updateSideMenu()
	}
	
	// MARK: Swipe Cell
	
	func swipeableTableViewCell(_ cell: SWTableViewCell!, canSwipeTo state: SWCellState) -> Bool {
		return true
	}
	
	func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerLeftUtilityButtonWith index: Int) {
		if let indexPath = tableView.indexPath(for: cell) {
			let conversation = fetchedObjects[indexPath.row]
			ActionPluginProvider.messageCellPluginForInboxType(MailboxType.Inbox)?.leftButtonTriggered(index, data: conversation, callback: nil)
		}
	}
	
	func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
		if let indexPath = tableView.indexPath(for: cell) {
			let conversation = fetchedObjects[indexPath.row]
			ActionPluginProvider.messageCellPluginForInboxType(MailboxType.Inbox)?.rightButtonTriggered(index, data: conversation, callback: nil)
		}
	}
	
	func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
		return true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		if segue.identifier == "showConversationTableViewController" {
			if let destination = segue.destination as? ConversationTableViewController {
				destination.conversation = activeConversation
				// OTTODO: Pass identifier instead of the fetchedSet?
				destination.allConversations = self.fetchedObjects
			}
		}
	}
	
	// MARK: Empty Dataset DataSource
	func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        if(emptyView == nil) {
		emptyView = Bundle.main.loadNibNamed("EmptyInboxView", owner: self, options: nil)?.first as?
            EmptyInboxView
        }
		emptyView?.actionButton.addTarget(self, action: #selector(InboxTableViewController.composeNewMessage),
		                                  for: .touchUpInside)
        emptyView?.waitingView.isHidden = true;
		return emptyView
	}
}

