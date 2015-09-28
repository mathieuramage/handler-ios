//
//  SendInvitationView.swift
//  Handler
//
//  Created by Christian Praiss on 28/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

@IBDesignable
class SendInvitationView: UIView {
	
	var showWindow: UIWindow?

	class func fromNib()->SendInvitationView {
		if let view = UINib(nibName: "SendInvitationView", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil).first as? SendInvitationView {
			return view
		}else {
			return SendInvitationView()
		}
	}

	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var profileImageView: WhiteBorderImageView!
	
	@IBOutlet weak var inviteTextLabel: UILabel!

	@IBOutlet weak var bySMSButton: UIButton!
	@IBOutlet weak var byTweetButton: UIButton!
	
	@IBAction func byTweetPressed(sender: UIButton) {
		
	}
	@IBAction func bySMSPressed(sender: UIButton) {
		
	}
}
