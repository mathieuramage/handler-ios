//
//  DraftsMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData
import Async
import DZNEmptyDataSet

class DraftsMailboxViewController: AbstractMessageMailboxViewController {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Drafts
		fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: MessageDao.draftsFetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
	}
    
    func customViewForEmptyDataSet(_ scrollView: UIScrollView!) -> UIView! {
        let view = Bundle.main.loadNibNamed("EmptyInboxView", owner: self, options: nil)?.first as! EmptyInboxView
        view.imageView.image = UIImage(named: "Empty Inbox Illustration")
        view.descriptionLabel.text = "Your draft emails will be here."
        view.actionButton.setTitle("Compose your first email", for: UIControlState())
        view.actionButton.addTarget(self, action: #selector(DraftsMailboxViewController.composeNewMessage), for: .touchUpInside)
        return view
    }
}
