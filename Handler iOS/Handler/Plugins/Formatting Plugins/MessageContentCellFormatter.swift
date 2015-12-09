//
//  MessageContentCellFormatter.swift
//  Handler
//
//  Created by Christian Praiß on 12/9/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Async

struct MessageContentFormatter: MessageContentCellFormatter {
    
    var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }()
    
    func populateView(data message: Message, view: MessageContentTableViewCell){
        view.contentLabel.text = message.content ?? "No content"
    }
    
    func populateView(data message: Message, view: MessageSenderTableViewCell){
        view.senderLabel.text = message.sender?.name
        view.senderHandleButton.setTitle("@" + (message.sender?.handle ?? ""), forState: .Normal)
        view.recipientLabel.text = "Need info here"
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