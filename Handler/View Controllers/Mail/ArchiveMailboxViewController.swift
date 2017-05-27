//
//  ArchieveMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData

class ArchiveMailboxViewController: AbstractMessageMailboxViewController {

    var waitingView: EmptyInboxView?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Archive
		fetchedResultsController = NSFetchedResultsController<Message>(
			fetchRequest: MessageDao.archiveFetchRequest,
			managedObjectContext: CoreDataStack.shared.viewContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// APICommunicator.sharedInstance.flushOldArchivedMessages()
		//TODO : Do the above
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let space = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
			target: nil,
			action: nil)
		
		navigationItem.rightBarButtonItem?.isEnabled = true
		
		lastupdatedLabel = UILabel(frame: CGRect(x: 0, y: 8, width: 140, height: 14))
		lastupdatedLabel?.textAlignment = .center
		lastupdatedLabel?.font = UIFont.systemFont(ofSize: 11)
		lastupdatedLabel?.textColor = UIColor(rgba: HexCodes.darkGray)
		
		let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 44))
		containerView.addSubview(lastupdatedLabel!)
		let item = UIBarButtonItem(customView: containerView)
		
		let composeItem = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.compose,
			target: self,
			action: #selector(InboxTableViewController.composeNewMessage))
		
		self.navigationController!.toolbar.items = [space, item, space, composeItem]
		showTitleFadeIn(title: "Archive")
	}

	func customViewForEmptyDataSet(_ scrollView: UIScrollView!) -> UIView! {
        if waitingView == nil {
		waitingView = Bundle.main.loadNibNamed("EmptyInboxView", owner: self,
			options: nil)?.first as? EmptyInboxView
        }
		waitingView?.imageView.image = UIImage(named: "mailbox_archive_empty")
		waitingView?.descriptionLabel.text = "Your archived emails will be here."
		waitingView?.actionButton.addTarget(
			self, action: #selector(ArchiveMailboxViewController.composeNewMessage), for: .touchUpInside)
		return view
	}
}
