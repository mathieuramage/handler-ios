//
//  MessageContentCellFormatter.swift
//  Handler
//
//  Created by Christian Praiß on 12/9/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Async

struct ConversationContentFormatter: MessageContentCellFormatter {
    
    var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }()
    
    func populateView(data message: Message, view: MessageContentTableViewCell){
        view.textString = message.content ?? "No content"
    }
    
    func populateView(data message: Message, view: MessageSenderTableViewCell){
        view.senderLabel.text = message.sender?.name
        view.senderHandleButton.setTitle("@" + (message.sender?.handle ?? ""), forState: .Normal)
        if let recipient = message.recipients?.allObjects.first as? User, let displayName = recipient.name, let handle = recipient.handle {
            view.recipientLabel.text = "To: " + displayName + " @" + handle
        }else{
            view.recipientLabel.text = "To: -"
        }
        view.sender = message.sender
        view.timeStampeLabel.text = timeFormatter.stringFromDate(message.sent_at ?? NSDate())
        if let string = message.sender?.profile_picture_url,  let profileUrl = NSURL(string: string) {
            view.senderImageView.kf_setImageWithURL(profileUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                Async.main(block: { () -> Void in
                    view.senderImageView.image = image
                })
            })
        }
    }
}