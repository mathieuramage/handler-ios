//
//  ConversationTableViewCellHelper.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 08/09/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import Kingfisher

class ConversationTableViewCellHelper: NSObject {

	static var timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.long
		formatter.timeStyle = DateFormatter.Style.short
		return formatter
	}()

	class func configureCell(_ cell : ConversationMessageTableViewCell, message: Message){

		cell.richTextContent.editingEnabled = false
        cell.richTextContent.set(html: message.content ?? "No content")
		cell.contentHeightConstraint.constant = CGFloat(cell.richTextContent.editorHeight)
		cell.richTextContent.webView.dataDetectorTypes = [.all]
		cell.richTextContent.backgroundColor = UIColor.clear
		cell.richTextContent.webView.backgroundColor = UIColor.clear
		cell.richTextContent.webView.scrollView.backgroundColor = UIColor.clear
		cell.richTextContent.webView.isOpaque = false
		cell.senderLabel.text = message.sender?.name
		cell.senderHandleButton.setTitle("@" + (message.sender?.handle ?? ""), for: UIControlState())

		let recipient = message.recipients?.allObjects.first as! User
		let displayName = recipient.name
		if recipient.handle.characters.count > 0 {
			cell.recipientLabel.text = "To: " + (displayName) + " @" + (recipient.handle)
		} else {
			cell.recipientLabel.text = "To: -"
		}
		cell.sender = message.sender
		cell.timeStampeLabel.text = timeFormatter.string(from: message.createdAt! as Date)
		if let pictureURL = message.sender?.pictureUrl {
            cell.senderImageView.kf.setImage(with: pictureURL, placeholder: UIImage.randomGhostImage(), options: nil, progressBlock: nil, completionHandler: nil)           
		}
	}

	class func configureCell(_ cell : ConversationMessageTableViewCell, message: Message, lastMessage: Bool, primary: Bool) {

		configureCell(cell, message: message)

		var bgColor: UIColor?

		if (primary) {
			bgColor = UIColor.white
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
