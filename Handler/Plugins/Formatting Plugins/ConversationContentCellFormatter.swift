//
//  MessageContentCellFormatter.swift
//  Handler
//
//  Created by Christian Praiß on 12/9/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

struct ConversationContentFormatter: MessageContentCellFormatter { // TODO Delete this class.
	
	var timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.long
		formatter.timeStyle = DateFormatter.Style.short
		return formatter
	}()

//	func populateView(data message: LegacyMessage?, view: ThreadMessageTableViewCell) {
//		view.richTextContent.editingEnabled = false
//		view.richTextContent.setHTML(message?.content ?? "No content")
//		view.contentHeightConstraint.constant = CGFloat(view.richTextContent.editorHeight)
//		view.richTextContent.webView.dataDetectorTypes = [.All]
//		view.richTextContent.backgroundColor = UIColor.clearColor()
//		view.richTextContent.webView.backgroundColor = UIColor.clearColor()
//		view.richTextContent.webView.scrollView.backgroundColor = UIColor.clearColor()
//		view.richTextContent.webView.opaque = false
//		view.senderLabel.text = message?.sender?.name
//		view.senderHandleButton.setTitle("@" + (message?.sender?.handle ?? ""), forState: .Normal)
//		if let recipient = message?.recipients?.allObjects.first as? LegacyUser, let displayName = recipient.name, let handle = recipient.handle {
//			view.recipientLabel.text = "To: " + displayName + " @" + handle
//		}
//		else {
//			view.recipientLabel.text = "To: -"
//		}
//		view.sender = message?.sender
//		view.timeStampeLabel.text = timeFormatter.stringFromDate(message?.sent_at ?? NSDate())
//		if let string = message?.sender?.profile_picture_url, let profileUrl = NSURL(string: string) {
//			view.senderImageView.kf_setImageWithURL(profileUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: nil)
//		}
//	}

//	func populateView(data message: LegacyMessage?, view: ThreadMessageTableViewCell, lastMessage: Bool, primary: Bool) {
//		self.populateView(data: message, view: view)
//
//		var bgColor: UIColor?
//
//		if (primary) {
//			bgColor = UIColor.whiteColor()
//		}
//		else {
//			bgColor = UIColor(rgba: HexCodes.offWhite)
//		}
//
//		view.contentView.backgroundColor = bgColor
//
//		if (lastMessage) {
//			view.separatorContainerHeightConstraint.constant = 0
//		}
//		else {
//			view.separatorContainerHeightConstraint.constant = 44
//		}
//	}
}
