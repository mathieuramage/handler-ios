//
//  ArchieveMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class ArchiveMailboxViewController: AbstractMailboxViewController {

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Archive
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		APICommunicator.sharedInstance.flushOldArchivedMessages()
	}

	func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
		let view = NSBundle.mainBundle().loadNibNamed("EmptyInboxView", owner: self, options: nil).first as! EmptyInboxView
		view.imageView.image = UIImage(named: "mailbox_archive_empty")
		view.descriptionLabel.text = "Your archive emails will be here."
		view.actionButton.addTarget(self, action: #selector(ArchiveMailboxViewController.composeNewMessage), forControlEvents: .TouchUpInside)
		return view
	}
}
