//
//  ContactCardViewController.swift
//  Handler
//
//  Created by Christian Praiss on 30/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import SwiftyJSON
import Async
import Kingfisher

class ContactCardViewController: UIViewController, UIViewControllerShow {
	
	@IBOutlet weak var profileImageView: WhiteBorderImageView!
	@IBOutlet weak var bannerImageView: UIImageView!
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var handleLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var followingCountLabel: UILabel!
	@IBOutlet weak var followersCountLabel: UILabel!
	
	@IBOutlet weak var websiteLinkButton: UIButton!
	
	@IBOutlet weak var topCardContrainst: NSLayoutConstraint!
	@IBOutlet weak var bottomCloseButtonConstraint: NSLayoutConstraint!

	var window: UIWindow?
	
	var openURL: NSURL?
	
	var handle: String? {
		didSet {
			if let handle = handle {
				getDataWithHandle(handle)
			}
		}
	}
	
	var user: LegacyUser? {
		didSet {
			if let user = user, let handle = user.handle {
				getDataWithHandle(handle)
			}
		}
	}
	
	func getDataWithHandle(handle: String){
		TwitterAPICommunicator.getAccountInfoForTwitterUser(handle, callback: { (json, error) -> Void in
			guard let json = json else {
				print(error)
				return
			}
			Async.main {
				self.statusLabel.text = json["description"].stringValue
				self.handleLabel.text = "@" + json["screen_name"].stringValue
				self.nameLabel.text = json["name"].stringValue
				self.locationLabel.text = json["location"].stringValue
				
				self.followersCountLabel.text = json["followers_count"].stringValue
				self.followingCountLabel.text = json["friends_count"].stringValue
				self.openURL = NSURL(string: json["entities"]["url"]["urls"][0]["expanded_url"].stringValue)
				self.websiteLinkButton.setTitle(json["entities"]["url"]["urls"][0]["display_url"].stringValue, forState: UIControlState.Normal)
				
				if let urlString = json["profile_banner_url"].string, let url = NSURL(string: urlString + DEFAULT_BANNER_RESOLUTION){
					self.bannerImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "twitter_default"), optionsInfo: [.Transition(ImageTransition.Fade(0.3))])
				}
				if let urlString = json["profile_image_url"].string, let url = NSURL(string: urlString){
					self.profileImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "twitter_default"), optionsInfo: [.Transition(ImageTransition.Fade(0.3))])
				}
				
				UIView.animateWithDuration(0.3, animations: { () -> Void in
					self.view.layoutSubviews()
				})
				
			}
		})
	}
	
	class func showWithUser(user: LegacyUser){
		var contactCard = ContactCardViewController(nibName: "ContactCardViewController", bundle: nil)
		contactCard.user = user
		contactCard.show()
	}
	
	class func showWithHandle(handle: String){
		var contactCard = ContactCardViewController(nibName: "ContactCardViewController", bundle: nil)
		contactCard.handle = handle
		contactCard.show()
	}
	
	@IBAction func urlButtonPressed(sender: UIButton) {
		if let url = openURL where UIApplication.sharedApplication().canOpenURL(url){
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let height = max(UIScreen.mainScreen().bounds.size.height, UIScreen.mainScreen().bounds.size.width)
		let is4InchScreen = height >= 568 && height < 667

		if is4InchScreen {
			topCardContrainst.constant = 64
			bottomCloseButtonConstraint.active = false
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func dismissPressed(sender: AnyObject?) {
		dismiss()
	}
	
	@IBAction func dismiss(){
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.window?.alpha = 0
			UIApplication.sharedApplication().statusBarStyle = .LightContent
			}) { (success) -> Void in
				self.window = nil
		}
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
