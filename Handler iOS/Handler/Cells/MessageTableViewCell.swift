//
//  MessageTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

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
				messageTimeLabel.text = timeFormatter.stringForTimeInterval(message.sent_at!.timeIntervalSinceNow)
				if message.isUnread {
					readFlaggedImageView.image = UIImage(named: "blue dot sm copy")
				}
			}
		}
	}
	
	func refreshFlags(){
		if message?.isUnread ?? false {
			readFlaggedImageView.image = UIImage(named: "blue dot sm copy")
		}
	}
	
	func leftButtons()->[AnyObject] {
		let array = NSMutableArray()
		array.sw_addUtilityButtonWithColor(UIColor.hrBlueColor(), icon: UIImage(named: "Mark_Unread_icon"), andTitle: "Unread")
		return array as [AnyObject]
	}
	
	func rightButtons()->[AnyObject] {
		let array = NSMutableArray()
		array.sw_addUtilityButtonWithColor(UIColor.hrLightGrayColor(), icon: UIImage(named: "More_Dots_Icon"), andTitle: "More")
		array.sw_addUtilityButtonWithColor(UIColor.hrOrangeColor(), icon: UIImage(named: "Flag_Icon"), andTitle: "Flag")
		array.sw_addUtilityButtonWithColor(UIColor.hrDarkBlueColor(), icon: UIImage(named: "Archive_Icon"), andTitle: "Archive")

		return array as [AnyObject]
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
	}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
