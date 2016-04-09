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
	@IBOutlet var recipientDividerView: UIView!
	@IBOutlet var recipientDividerHeightConstraint: NSLayoutConstraint!
	@IBOutlet var messageDividerView: UIView!
	@IBOutlet var messageDividerHeightContraint: NSLayoutConstraint!
	@IBOutlet var separatorLineView: UIView!
	@IBOutlet var separatorLineHeightConstraint: NSLayoutConstraint!

	@IBOutlet var threadLine: UIView!

	var sender: User?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.recipientDividerView.backgroundColor = UIColor(rgba: HexCodes.lightGray)
		self.messageDividerView.backgroundColor = UIColor(rgba: HexCodes.lightGray)
		self.separatorLineView.backgroundColor = UIColor(rgba: HexCodes.lightGray)
		self.threadLine.backgroundColor = UIColor(rgba: HexCodes.lighterGray)
		self.recipientDividerHeightConstraint.constant = 1/UIScreen.mainScreen().scale
		self.messageDividerHeightContraint.constant = 1/UIScreen.mainScreen().scale
		self.separatorLineHeightConstraint.constant = 1/UIScreen.mainScreen().scale
		
	}

	@IBAction func didPressUsername(sender: UIButton) {
		if let sender = self.sender {
			ContactCardViewController.showWithUser(sender)
		}
	}
}
