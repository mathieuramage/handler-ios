//
//  DraftsFormatter.swift
//  Handler
//
//  Created by Guillaume Kermorgant on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Async

struct DraftsFormatter: MessageTableViewCellFormatter {
    
    var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }()
    
    func populateView(data message: ManagedMessage, view: MessageTableViewCell){
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
        if let urlString = message.sender?.profile_picture_url, let profileUrl = NSURL(string: urlString) {
            view.senderProfileImageView.kf_setImageWithURL(profileUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in

            })
        }
        
        view.senderNameLabel.text = message.sender?.name
        if let handle = message.sender?.handle {
            view.senderHandleLabel.text = "@" + handle
        }
        view.messageSubjectLabel.text = message.subject
        view.messageContentPreviewLabel.text = message.content
        if let updatedAt = message.updatedAt {
            view.messageTimeLabel.text = timeFormatter.stringFromDate(updatedAt)
        } else {
            view.messageTimeLabel.text = "-"
        }

		if let count = message.conversation?.messages?.count where count > 1 {
			view.threadCountLabel.hidden = false
			view.threadCountLabel.text = "\(count)"
		} else {
			view.threadCountLabel.hidden = true
			view.threadCountLabel.text = "-"
		}

		// TODO: Support Attachments
		//        if let count = message.attachments?.count where count > 1 {
		//            view.attachmentIconView.hidden = false
		//        } else {
		view.attachmentIconView.hidden = true
		//        }

		if message.conversation?.mostRecentMessage?.sender?.id == AuthUtility.user?.identifier {
			view.repliedIconView.hidden = false
		} else {
			view.repliedIconView.hidden = true
		}
        setUpReadFlagMessage(data: message, view: view)

    }
    
    func refreshFlags(data message: ManagedMessage, view: MessageTableViewCell){
        setUpReadFlagMessage(data: message, view: view)
    }
    
    func setUpReadFlagMessage(data message: ManagedMessage, view: MessageTableViewCell) {
        if message.isFlagged && message.isUnread {
            view.readFlaggedImageView.image = UIImage(named: "Orange_Dot")
            // TODO: Add blue button encircled by orange
        }
        else if message.isFlagged {
            view.readFlaggedImageView.image = UIImage(named: "Orange_Dot")
        }
        else if message.isUnread {
            view.readFlaggedImageView.image = UIImage(named: "Blue_Dot")
        }
        else {
            view.readFlaggedImageView.image = nil
        }
    }
    
    func leftButtonsForData(data message: ManagedMessage)->[AnyObject]{
        return ActionPluginProvider.messageCellPluginForInboxType(.Drafts)?.leftButtonsForData(data: message) ?? [AnyObject]()
    }
    
    func rightButtonsForData(data message: ManagedMessage)->[AnyObject]{
        return ActionPluginProvider.messageCellPluginForInboxType(.Drafts)?.rightButtonsForData(data: message) ?? [AnyObject]()
    }
}
