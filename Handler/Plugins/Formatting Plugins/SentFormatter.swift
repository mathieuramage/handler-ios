//
//  SentFormatter.swift
//  Handler
//
//  Created by Guillaume Kermorgant on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Async

struct SentFormatter: MessageTableViewCellFormatter {
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = DateFormatter.Style.none
        formatter.dateStyle = DateFormatter.Style.short
        return formatter
    }()
    
    func populateView(data message: Message, view: MessageTableViewCell){
        view.readFlaggedImageView.image = nil
        view.senderProfileImageView.image = nil
        view.senderNameLabel.text = nil
        view.senderHandleLabel.text = nil
        view.messageSubjectLabel.text = nil
        view.messageTimeLabel.text = nil
        view.messageContentPreviewLabel.text = nil
        view.leftUtilityButtons = nil
        view.rightUtilityButtons = nil
        
        view.leftUtilityButtons = leftButtonsForData(data: message)
        view.rightUtilityButtons = rightButtonsForData(data: message)
		
		if let twitterUser = message.recipients?.allObjects.first as? User {
			if let profileUrl = twitterUser.pictureUrl {
				view.senderProfileImageView.kf.setImage(with: profileUrl, placeholder: UIImage.randomGhostImage(), options: nil, progressBlock: nil, completionHandler: nil)
			}
		}
		
        view.senderNameLabel.text = (message.recipients?.allObjects.first as? User)?.name
        if let handle = (message.recipients?.allObjects.first as? User)?.handle {
            view.senderHandleLabel.text = "@" + handle
        }
        view.messageSubjectLabel.text = message.subject

        do {
            let parsedMessage = try NSAttributedString(data: (message.content?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
            view.messageContentPreviewLabel.text = parsedMessage.string
        } catch {
            view.messageContentPreviewLabel.text = message.content
        }
        
        
        if let createdAt = message.createdAt {
            view.messageTimeLabel.text = timeFormatter.string(from: createdAt as Date)
        } else {
            view.messageTimeLabel.text = "-"
        }

		if let count = message.conversation?.messages?.count, count > 1 {
			view.threadCountLabel.isHidden = false
			view.threadCountLabel.text = "\(count)"
		} else {
			view.threadCountLabel.isHidden = true
			view.threadCountLabel.text = "-"
		}

		// TODO: Support Attachments
		//        if let count = message.attachments?.count where count > 1 {
		//            view.attachmentIconView.hidden = false
		//        } else {
		view.attachmentIconView.isHidden = true
		//        }

		if message.conversation?.mostRecentMessage?.sender?.identifier == AuthUtility.user?.identifier {
			view.repliedIconView.isHidden = false
		} else {
			view.repliedIconView.isHidden = true
		}

        setUpReadFlagMessage(data: message, view: view)
        
    }
    
    func refreshFlags(data message: Message, view: MessageTableViewCell){
        setUpReadFlagMessage(data: message, view: view)
    }
    
    func setUpReadFlagMessage(data message: Message, view: MessageTableViewCell) {
        if message.starred && !message.read {
            view.readFlaggedImageView.image = UIImage(named: "read-and-flagged-icon")
        }
        else if message.starred {
            view.readFlaggedImageView.image = UIImage(named: "Orange_Dot")
        }
        else if !message.read {
            view.readFlaggedImageView.image = UIImage(named: "Blue_Dot")
        }
        else {
            view.readFlaggedImageView.image = nil
        }
    }
    
    func leftButtonsForData(data message: Message) -> [AnyObject]{
        return ActionPluginProvider.messageCellPluginForInboxType(.Sent)?.leftButtonsForData(data: message) ?? [AnyObject]()
    }
    
    func rightButtonsForData(data message: Message) -> [AnyObject]{
        return ActionPluginProvider.messageCellPluginForInboxType(.Sent)?.rightButtonsForData(data: message) ?? [AnyObject]()
    }
}
