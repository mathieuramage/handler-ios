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

class ContactLegacyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var user: LegacyUser? {
        didSet {
            if let urlString = user?.profile_picture_url, let profileUrl = NSURL(string: urlString) {
                self.profileImageView.kf_setImageWithURL(profileUrl, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                })
            }
            self.followButton.setImage(UIImage.imageForTwitterStatus(TwitterFriendshipStatus(rawValue: user?.twtterFollowStatus?.integerValue ?? 2)!), forState: UIControlState.Normal)
            self.followButton.enabled = user?.twtterFollowStatus?.integerValue < 2
            self.nameLabel.text = user?.name
            self.handleLabel.text = user?.handle
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func followButtonPressed(sender: UIButton) {
        
    }
}
