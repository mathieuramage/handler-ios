//
//  DraftsFormatter.swift
//  Handler
//
//  Created by Guillaume Kermorgant on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
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
        if let urlString = message.sender?.profile_picture_url, let profileUrl = NSURL(string: urlString) {
            view.senderProfileImageView.kf_setImageWithURL(profileUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                Async.main(block: { () -> Void in
                    view.senderProfileImageView.image = image
                })
            })
        }
        
        view.senderNameLabel.text = message.sender?.name
        if let handle = message.sender?.handle {
            view.senderHandleLabel.text = "@" + handle
        }
        view.messageSubjectLabel.text = message.subject
        view.messageContentPreviewLabel.text = message.content
        if let sent_at = message.sent_at {
            
            view.messageTimeLabel.text = timeFormatter.stringFromDate(sent_at)
        }else{
            view.messageTimeLabel.text = "-"
        }
        setUpReadFlagMessage(data: message, view: view)
        
    }
    
    func refreshFlags(data message: Message, view: MessageTableViewCell){
        setUpReadFlagMessage(data: message, view: view)
    }
    
    func setUpReadFlagMessage(data message: Message, view: MessageTableViewCell) {
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
    
    func leftButtonsForData(data message: Message)->[AnyObject]{
        return ActionPluginProvider.messageCellPluginForInboxType(.Drafts)?.leftButtonsForData(data: message) ?? [AnyObject]()
    }
    
    func rightButtonsForData(data message: Message)->[AnyObject]{
        return ActionPluginProvider.messageCellPluginForInboxType(.Drafts)?.rightButtonsForData(data: message) ?? [AnyObject]()
    }
}
