//
//  InboxMessageTableViewCellHelper.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 20/08/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

class InboxMessageTableViewCellHelper {

	static var timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeStyle = DateFormatter.Style.none
		formatter.dateStyle = DateFormatter.Style.short
		return formatter
	}()

	class func configureCell(_ cell : MessageTableViewCell, conversation: Conversation){

		guard let message = conversation.latestMessage else {
			return
		}

		cell.readFlaggedImageView.image = nil
		cell.senderProfileImageView.image = nil
		cell.senderNameLabel.text = nil
		cell.senderHandleLabel.text = nil
		cell.messageSubjectLabel.text = nil
		cell.messageTimeLabel.text = nil
		cell.messageContentPreviewLabel.text = nil
		cell.leftUtilityButtons = nil
		cell.rightUtilityButtons = nil

		if let pictureUrl = message.sender?.pictureUrl {
            cell.senderProfileImageView.kf.setImage(with: pictureUrl, placeholder: UIImage.randomGhostImage(), options: nil, progressBlock: nil, completionHandler: nil)
		}

		cell.senderNameLabel.text = message.sender?.name
		cell.senderHandleLabel.text = "@" + (message.sender?.handle ?? "")
		cell.messageSubjectLabel.text = message.subject
		
		do {
			let parsedMessage = try NSAttributedString(data: (message.content?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
			cell.messageContentPreviewLabel.text = parsedMessage.string
		} catch {
			cell.messageContentPreviewLabel.text = message.content
		}

		cell.messageTimeLabel.text = timeFormatter.string(from: message.createdAt! as Date)

		let count = conversation.messages?.count
		if let count = count, count > 1 {
			cell.threadCountLabel.isHidden = false
			cell.threadCountLabel.text = "\(count)"
		} else {
			cell.threadCountLabel.isHidden = true
			cell.threadCountLabel.text = "-"
		}

		cell.attachmentIconView.isHidden = true

		cell.repliedIconView.isHidden = (message.sender?.identifier != AuthUtility.user?.identifier)

		setUpReadFlagMessage(conversation: conversation, view: cell)
		cell.leftUtilityButtons = leftButtonsForMessage(conversation)
		cell.rightUtilityButtons = rightButtonsForMessage(conversation)
	}

//	class func refreshFlags(message: Message, view: MessageTableViewCell){
//		setUpReadFlagMessage(message: message, view: view)
//	}

	class func setUpReadFlagMessage(conversation: Conversation, view: MessageTableViewCell) {
		if conversation.hasFlaggedMessages && conversation.hasUnreadMessages {
			view.readFlaggedImageView.image = UIImage(named: "read-and-flagged-icon")
		} else if conversation.hasFlaggedMessages {
			view.readFlaggedImageView.image = UIImage(named: "Orange_Dot")
		} else if conversation.hasUnreadMessages {
			view.readFlaggedImageView.image = UIImage(named: "Blue_Dot")
		} else {
			view.readFlaggedImageView.image = nil
		}
	}

	class func leftButtonsForMessage(_ conversation: Conversation)->[AnyObject]{
		let array = NSMutableArray()
		let readIcon = UIImage(named: "icon_read")?.imageResize(sizeChange: CGSize(width: 25, height: 23))
		let unreadIcon = UIImage(named: "icon_unread")?.imageResize(sizeChange: CGSize(width: 25, height: 17))
		
		if !conversation.hasUnreadMessages {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.lightBlue), icon: unreadIcon)
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.lightBlue), icon: readIcon)
		}
		return array as [AnyObject]
	}

	class func rightButtonsForMessage(_ conversation: Conversation)->[AnyObject]{
		let array = NSMutableArray()
		let flagIcon = UIImage(named: "icon_flag")?.imageResize(sizeChange: CGSize(width: 25, height: 34))
		let unflagIcon = UIImage(named: "icon_unflag")?.imageResize(sizeChange: CGSize(width: 25, height: 44))
		let archiveIcon = UIImage(named: "icon_archive")?.imageResize(sizeChange: CGSize(width: 25, height: 20))
		let unarchiveIcon = UIImage(named: "icon_unarchive")?.imageResize(sizeChange: CGSize(width: 25, height: 21))
		
		if conversation.hasFlaggedMessages {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.orange), icon: unflagIcon)
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.orange), icon: flagIcon)
		}

		if conversation.hasArchivedMessages  {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.darkBlue), icon: unarchiveIcon)
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.darkBlue), icon: archiveIcon)
		}
		return array as [AnyObject]
	}
	
}
