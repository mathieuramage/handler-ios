//
//  ContactTableViewCell.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 22/4/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var handleLabel: UILabel!
	@IBOutlet weak var followButton: UIButton!

//	var user: User? {
//		didSet {
//			if let urlString = user?.profile_picture_url, let profileUrl = NSURL(string: urlString) {
//				self.profileImageView.kf_setImageWithURL(profileUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
//				})
//			}
//			self.followButton.setImage(UIImage.imageForTwitterStatus(TwitterFriendshipStatus(rawValue: user?.twtterFollowStatus?.integerValue ?? 2)!), forState: UIControlState.Normal)
//			self.followButton.enabled = user?.twtterFollowStatus?.integerValue < 2
//			self.nameLabel.text = user?.name
//			self.handleLabel.text = user?.handle
//
//		}
//	}
}
