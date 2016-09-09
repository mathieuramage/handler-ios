//
//  ConversationTableViewCellHelper.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 08/09/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

class ConversationTableViewCellHelper: NSObject {


	static var timeFormatter: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.dateStyle = NSDateFormatterStyle.LongStyle
		formatter.timeStyle = NSDateFormatterStyle.ShortStyle
		return formatter
	}()

	class func configureCell(cell : ConversationMessageTableViewCell, message: Message){

		cell.richTextContent.editingEnabled = false
		cell.richTextContent.setHTML(message.message ?? "No content")
		cell.contentHeightConstraint.constant = CGFloat(cell.richTextContent.editorHeight)
		cell.richTextContent.webView.dataDetectorTypes = [.All]
		cell.richTextContent.backgroundColor = UIColor.clearColor()
		cell.richTextContent.webView.backgroundColor = UIColor.clearColor()
		cell.richTextContent.webView.scrollView.backgroundColor = UIColor.clearColor()
		cell.richTextContent.webView.opaque = false
		cell.senderLabel.text = message.sender.name
		cell.senderHandleButton.setTitle("@" + (message.sender.handle), forState: .Normal)

		let recipient = message.recipients[0] as User
		let displayName = recipient.name
		if recipient.handle.characters.count > 0 {
			cell.recipientLabel.text = "To: " + displayName + " @" + recipient.handle
		} else {
			cell.recipientLabel.text = "To: -"
		}
		cell.sender = message.sender
		cell.timeStampeLabel.text = timeFormatter.stringFromDate(message.createdAt)
		if let pictureURL = message.sender.twitterUser.pictureURL {
			cell.senderImageView.kf_setImageWithURL(pictureURL, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: nil)
		}
	}

	class func configureCell(cell : ConversationMessageTableViewCell, message: Message, lastMessage: Bool, primary: Bool) {

		configureCell(cell, message: message)

		var bgColor: UIColor?

		if (primary) {
			bgColor = UIColor.whiteColor()
		}
		else {
			bgColor = UIColor(rgba: HexCodes.offWhite)
		}

		cell.contentView.backgroundColor = bgColor

		if (lastMessage) {
			cell.separatorContainerHeightConstraint.constant = 0
		}
		else {
			cell.separatorContainerHeightConstraint.constant = 44
		}
	}
	
}
