//
//  InboxFormatter.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Async

struct InboxFormatter: MessageTableViewCellFormatter {
    
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
        if message.isUnread {
            view.readFlaggedImageView.image = UIImage(named: "Blue_Dot")
        }
        
    }
        
    func refreshFlags(data message: Message, view: MessageTableViewCell){
        if message.isUnread {
            view.readFlaggedImageView.image = UIImage(named: "Blue_Dot")
        }else{
            view.readFlaggedImageView.image = nil
        }
    }
    
    func leftButtonsForData(data message: Message)->[AnyObject]{
        let array = NSMutableArray()
        if !message.isUnread {
            array.sw_addUtilityButtonWithColor(UIColor.hrBlueColor(), icon: UIImage(named: "Mark_Unread_icon"), andTitle: "Unread")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor.hrBlueColor(), icon: UIImage(named: "Mark_Read_icon"), andTitle: "Read")
        }
        return array as [AnyObject]
    }
    
    func rightButtonsForData(data message: Message)->[AnyObject]{
        let array = NSMutableArray()
            array.sw_addUtilityButtonWithColor(UIColor.hrLightGrayColor(), icon: UIImage(named: "More_Dots_Icon"), andTitle: "More")
            if message.isFlagged {
                array.sw_addUtilityButtonWithColor(UIColor.hrOrangeColor(), icon: UIImage(named: "Flag_Icon"), andTitle: "Unflag")
            }else{
                array.sw_addUtilityButtonWithColor(UIColor.hrOrangeColor(), icon: UIImage(named: "Flag_Icon"), andTitle: "Flag")
            }
            
            if message.isArchived {
                array.sw_addUtilityButtonWithColor(UIColor.hrDarkBlueColor(), icon: UIImage(named: "Archive_Icon"), andTitle: "Unarchive")
            }else{
                array.sw_addUtilityButtonWithColor(UIColor.hrDarkBlueColor(), icon: UIImage(named: "Archive_Icon"), andTitle: "Archive")
            }
        return array as [AnyObject]    }
}
