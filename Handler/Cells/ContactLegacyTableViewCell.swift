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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ContactLegacyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var user: ManagedUser? {
        didSet {
            if let urlString = user?.profile_picture_url, let profileUrl = URL(string: urlString) {
                self.profileImageView.kf.setImage(with: profileUrl, placeholder: UIImage.randomGhostImage(), options: nil, progressBlock: nil, completionHandler: nil)
            }
            
            self.followButton.setImage(UIImage.imageForTwitterStatus(TwitterFriendshipStatus(rawValue: user?.twtterFollowStatus?.intValue ?? 2)!), for: UIControlState())
            self.followButton.isEnabled = user?.twtterFollowStatus?.intValue < 2
            self.nameLabel.text = user?.name
            self.handleLabel.text = user?.handle
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        
    }
}
