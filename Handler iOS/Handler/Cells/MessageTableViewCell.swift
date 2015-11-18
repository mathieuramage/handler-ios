//
//  MessageTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Async

class MessageTableViewCell: SWTableViewCell {
    
    @IBOutlet weak var readFlaggedImageView: UIImageView!
    @IBOutlet weak var senderProfileImageView: UIImageView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var senderHandleLabel: UILabel!
    @IBOutlet weak var messageSubjectLabel: UILabel!
    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var messageContentPreviewLabel: UILabel!
    
    lazy var timeFormatter: TTTTimeIntervalFormatter = {
        let formatter = TTTTimeIntervalFormatter()
        formatter.usesIdiomaticDeicticExpressions = true
        formatter.presentTimeIntervalMargin = 60
        formatter.presentDeicticExpression = "now"
        return formatter
    }()
    
    var inboxType: MailboxType = .Inbox
    
    var message: Message? {
        didSet {
            
            readFlaggedImageView.image = nil
            senderProfileImageView.image = nil
            senderNameLabel.text = nil
            senderHandleLabel.text = nil
            messageSubjectLabel.text = nil
            messageTimeLabel.text = nil
            messageContentPreviewLabel.text = nil
            leftUtilityButtons = nil
            rightUtilityButtons = nil
            
            if let message = message {
                
                leftUtilityButtons = leftButtons()
                rightUtilityButtons = rightButtons()
                if let urlString = message.sender?.profile_picture_url, let profileUrl = NSURL(string: urlString) {
                    self.senderProfileImageView.kf_setImageWithURL(profileUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                        Async.main(block: { () -> Void in
                            self.senderProfileImageView.image = image
                        })
                    })
                }
                
                senderNameLabel.text = message.sender?.name
                if let handle = message.sender?.handle {
                    senderHandleLabel.text = "@" + handle
                }
                messageSubjectLabel.text = message.subject
                messageContentPreviewLabel.text = message.content
                if let sent_at = message.sent_at {
                    messageTimeLabel.text = timeFormatter.stringForTimeInterval(sent_at.timeIntervalSinceNow)
                }else{
                    messageTimeLabel.text = "-"
                }
                if message.isUnread {
                    readFlaggedImageView.image = UIImage(named: "blue dot sm copy")
                }
            }
        }
    }
    
    func refreshFlags(){
        if message?.isUnread ?? false {
            readFlaggedImageView.image = UIImage(named: "blue dot sm copy")
        }else{
            readFlaggedImageView.image = nil
        }
    }
    
    func leftButtons()->[AnyObject] {
        let array = NSMutableArray()
        if let unread = message?.isUnread where unread {
            array.sw_addUtilityButtonWithColor(UIColor.hrBlueColor(), icon: UIImage(named: "Mark_Unread_icon"), andTitle: "Unread")
        }
        return array as [AnyObject]
    }
    
    func rightButtons()->[AnyObject] {
        let array = NSMutableArray()
        array.sw_addUtilityButtonWithColor(UIColor.hrLightGrayColor(), icon: UIImage(named: "More_Dots_Icon"), andTitle: "More")
        if let isFlagged = message?.isFlagged where isFlagged {
            array.sw_addUtilityButtonWithColor(UIColor.hrOrangeColor(), icon: UIImage(named: "Flag_Icon"), andTitle: "Unflag")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor.hrOrangeColor(), icon: UIImage(named: "Flag_Icon"), andTitle: "Flag")
        }
        
        if let isArchived = message?.isArchived where isArchived {
            array.sw_addUtilityButtonWithColor(UIColor.hrDarkBlueColor(), icon: UIImage(named: "Archive_Icon"), andTitle: "Unarchive")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor.hrDarkBlueColor(), icon: UIImage(named: "Archive_Icon"), andTitle: "Archive")
        }
        
        return array as [AnyObject]
    }
}
