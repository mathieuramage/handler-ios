//
//  MessageTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

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
		
	var message: Message? {
		didSet {
			
			readFlaggedImageView.image = nil
			senderProfileImageView.image = nil
			senderNameLabel.text = nil
			senderHandleLabel.text = nil
			messageSubjectLabel.text = nil
			messageTimeLabel.text = nil
			messageContentPreviewLabel.text = nil
			
			if let message = message {
				if let urlString = message.sender?.profile_picture_url, let profileUrl = NSURL(string: urlString) {
					senderProfileImageView.sd_setImageWithURL(profileUrl)
				}
				senderNameLabel.text = message.sender?.name
				if let handle = message.sender?.handle {
					senderHandleLabel.text = "@" + handle
				}
				messageSubjectLabel.text = message.subject
				messageContentPreviewLabel.text = message.content
				messageTimeLabel.text = timeFormatter.stringForTimeInterval(NSDate().timeIntervalSinceDate(message.sent_at!))
				if message.isUnread {
					readFlaggedImageView.image = UIImage(named: "blue dot sm copy")
				}
			}
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
