//
//  UnreadMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class UnreadMailboxViewController: AbstractMailboxViewController {

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Unread
	}

	func customViewForEmptyDataSet(_ scrollView: UIScrollView!) -> UIView! {
		let view = Bundle.main.loadNibNamed("EmptyInboxView", owner: self, options: nil)?.first as! EmptyInboxView
		view.imageView.image = UIImage(named: "mailbox_unread_empty")
		view.descriptionLabel.text = "Your unread emails will be here."
		view.actionButton.setTitle("Compose your first email", for: UIControlState())
		view.actionButton.addTarget(self, action: #selector(FlaggedMailboxViewController.composeNewMessage), for: .touchUpInside)
		return view
	}
}
