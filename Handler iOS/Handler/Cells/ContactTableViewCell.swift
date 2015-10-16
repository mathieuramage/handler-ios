//
//  ContactTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 16/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Async
import Kingfisher

class ContactTableViewCell: UITableViewCell {

	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var handleLabel: UILabel!
	@IBOutlet weak var followButton: UIButton!
	
	var user: User? {
		didSet {
			if let urlString = user?.profile_picture_url, let profileUrl = NSURL(string: urlString) {
				Async.background(block: { () -> Void in
					self.profileImageView.kf_setImageWithURL(profileUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
						Async.main(block: { () -> Void in
							self.profileImageView.image = image
						})
					})
				})
			}
			self.followButton.setImage(UIImage.imageForTwitterStatus(TwitterFriendshipStatus(rawValue: user?.twtterFollowStatus?.integerValue ?? 2)!), forState: UIControlState.Normal)
			self.nameLabel.text = user?.name
			self.handleLabel.text = user?.handle
			
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

	@IBAction func followButtonPressed(sender: UIButton) {
		
	}
}
