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
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Archive
		fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: MessageDao.archiveFetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// APICommunicator.sharedInstance.flushOldArchivedMessages()
		//TODO : Do the above
	}
	
	func customViewForEmptyDataSet(_ scrollView: UIScrollView!) -> UIView! {
		let view = Bundle.main.loadNibNamed("EmptyInboxView", owner: self, options: nil)?.first as! EmptyInboxView
		view.imageView.image = UIImage(named: "mailbox_archive_empty")
		view.descriptionLabel.text = "Your archived emails will be here."
		view.actionButton.addTarget(self, action: #selector(ArchiveMailboxViewController.composeNewMessage), for: .touchUpInside)
		return view
	}
}
