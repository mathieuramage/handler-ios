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
	
	var openURL: URL?
	
	var handle: String? {
		didSet {
			if let handle = handle {
				getDataWithHandle(handle)
			}
		}
	}
	
	var user: ManagedUser? {
		didSet {
			if let user = user {
				getDataWithHandle(user.handle)
			}
		}
	}
	
	func getDataWithHandle(_ handle: String){
		TwitterAPIOperations.getAccountInfoForTwitterUser(handle, callback: { (json, error) -> Void in
			guard let json = json else {
				print(error as Any)
				return
			}
			Async.main {
				self.statusLabel.text = json["description"].stringValue
				self.handleLabel.text = "@" + json["screen_name"].stringValue
				self.nameLabel.text = json["name"].stringValue
				self.locationLabel.text = json["location"].stringValue
				
				self.followersCountLabel.text = json["followers_count"].stringValue
				self.followingCountLabel.text = json["friends_count"].stringValue
				self.openURL = URL(string: json["entities"]["url"]["urls"][0]["expanded_url"].stringValue)
				self.websiteLinkButton.setTitle(json["entities"]["url"]["urls"][0]["display_url"].stringValue, for: UIControlState.normal)
				
				if let urlString = json["profile_banner_url"].string, let url = URL(string: urlString + DEFAULT_BANNER_RESOLUTION){
                    self.bannerImageView.kf.setImage(with: url, placeholder: UIImage(named : "twitter_default"), options: [.transition(ImageTransition.fade(0.3))], progressBlock: nil, completionHandler: nil)
				}
				if let urlString = json["profile_image_url"].string, let url = URL(string: urlString){
                    self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named : "twitter_default"), options:  [.transition(ImageTransition.fade(0.3))], progressBlock: nil, completionHandler: nil)
				}
                
                UIView.animate(withDuration: 0.3, animations: { 
                    self.view.layoutSubviews()
                })
				
			}
		})
	}
	
	class func showWithUser(_ user: ManagedUser){
		var contactCard = ContactCardViewController(nibName: "ContactCardViewController", bundle: nil)
		contactCard.user = user
		contactCard.show()
	}
	
	class func showWithHandle(_ handle: String){
		var contactCard = ContactCardViewController(nibName: "ContactCardViewController", bundle: nil)
		contactCard.handle = handle
		contactCard.show()
	}
	
	@IBAction func urlButtonPressed(_ sender: UIButton) {
		if let url = openURL, UIApplication.shared.canOpenURL(url){
			UIApplication.shared.openURL(url)
		}
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let height = max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width)
		let is4InchScreen = height >= 568 && height < 667

		if is4InchScreen {
			topCardContrainst.constant = 64
			bottomCloseButtonConstraint.isActive = false
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func dismissPressed(_ sender: AnyObject?) {
		dismiss()
	}
	
	@IBAction func dismiss() {
		UIView.animate(withDuration: 0.3, animations: { () -> Void in
			self.window?.alpha = 0
			UIApplication.shared.statusBarStyle = .lightContent
			}, completion: { (success) -> Void in
				self.window = nil
		}) 
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
}
