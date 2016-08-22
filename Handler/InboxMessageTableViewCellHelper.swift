//
//  InboxMessageTableViewCellHelper.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 20/08/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

class InboxMessageTableViewCellHelper {

	static var timeFormatter: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.timeStyle = NSDateFormatterStyle.NoStyle
		formatter.dateStyle = NSDateFormatterStyle.ShortStyle
		return formatter
	}()

	class func configureCell(cell : MessageTableViewCell, message: Message){
		cell.readFlaggedImageView.image = nil
		cell.senderProfileImageView.image = nil
		cell.senderNameLabel.text = nil
		cell.senderHandleLabel.text = nil
		cell.messageSubjectLabel.text = nil
		cell.messageTimeLabel.text = nil
		cell.messageContentPreviewLabel.text = nil
		cell.leftUtilityButtons = nil
		cell.rightUtilityButtons = nil

		//todo view.leftUtilityButtons = leftButtonsForMessage(message)
		//todo view.rightUtilityButtons = rightButtonsForMessage(message)
		if let pictureUrl = message.sender.twitterPictureUrl {
			cell.senderProfileImageView.kf_setImageWithURL(pictureUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
			})
		}

		cell.senderNameLabel.text = message.sender.name
		cell.senderHandleLabel.text = "@" + message.sender.twitterUserName!

		cell.messageSubjectLabel.text = message.subject
		cell.messageContentPreviewLabel.text = message.message
		//		view.messageContentPreviewLabel.text = message.content
		//		if let sent_at = message.sent_at {
		//
		//			view.messageTimeLabel.text = timeFormatter.stringFromDate(sent_at)
		//		}else{
		//			view.messageTimeLabel.text = "-"
		//		}

		cell.messageTimeLabel.text = timeFormatter.stringFromDate(message.createdAt)

		//		if let count = message.thread?.messages?.count where count > 1 {
		//			view.threadCountLabel.hidden = false
		//			view.threadCountLabel.text = "\(count)"
		//		}else{
		//			view.threadCountLabel.hidden = true
		//			view.threadCountLabel.text = "-"
		//		}

		//		if let count = message.attachments?.count where count > 1 {
		//			view.attachmentIconView.hidden = false
		//		}else{
		//			view.attachmentIconView.hidden = true
		//		}
		//
		//		if message.thread?.mostRecentMessage?.sender?.id == HRUserSessionManager.sharedManager.currentUser?.id {
		//			view.repliedIconView.hidden = false
		//		}else{
		//			view.repliedIconView.hidden = true
		//		}

		setUpReadFlagMessage(message: message, view: cell)

	}

	class func refreshFlags(message message: Message, view: MessageTableViewCell){
		setUpReadFlagMessage(message: message, view: view)
	}

	class func setUpReadFlagMessage(message message: Message, view: MessageTableViewCell) {
		if message.starred == true && !message.read {
			view.readFlaggedImageView.image = UIImage(named: "Orange_Dot")
			// TODO: Add blue button encircled by orange
		}
		else if message.starred == true {
			view.readFlaggedImageView.image = UIImage(named: "Orange_Dot")
		}
		else if message.starred == true {
			view.readFlaggedImageView.image = UIImage(named: "Blue_Dot")
		}
		else {
			view.readFlaggedImageView.image = nil
		}
	}


	func leftButtonsForMessage(message message: Message)->[AnyObject]{
		let array = NSMutableArray()
		if !message.read {
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "icon_read"))
		}else{
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "icon_unread"))
		}
		return array as [AnyObject]
	}

	func rightButtonsForData(message message: Message)->[AnyObject]{
		let array = NSMutableArray()
		if message.starred == true {
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.orange), icon: UIImage(named: "icon_unflag"))
		}else{
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.orange), icon: UIImage(named: "icon_flag"))
		}

		if message.archived  {
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "icon_unarchive"))
		}else{
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "icon_archive"))
		}
		return array as [AnyObject]
	}
	
}
