//
//  ThreadMessageTableViewCell.swift
//  Handler
//
//  Created by Christian Praiß on 12/9/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class ThreadMessageTableViewCell: UITableViewCell {

	@IBOutlet var senderLabel: UILabel!
	@IBOutlet var senderHandleButton: UIButton!
	@IBOutlet var recipientLabel: UILabel!
	@IBOutlet var timeStampeLabel: UILabel!
	@IBOutlet var senderImageView: UIImageView!
	@IBOutlet var contentTextView: UITextView!
	@IBOutlet var dotImageView: UIImageView!
	@IBOutlet var separatorContainerHeightConstraint: NSLayoutConstraint!

	var sender: User?

	@IBAction func didPressUsername(sender: UIButton) {
		if let sender = self.sender {
			ContactCardViewController.showWithUser(sender)
		}
	}
}
