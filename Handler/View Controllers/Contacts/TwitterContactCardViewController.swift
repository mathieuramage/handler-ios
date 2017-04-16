//
//  TwitterContactCardViewController.swift
//  Handler
//
//  Created by Marco Antonio Nascimento on 15.04.17.
//  Copyright © 2017 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async
import Kingfisher

class TwitterContactCardViewController: UIViewController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var handleButton: UIButton!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var followingCountLabel: UILabel!
	@IBOutlet weak var followersCountLabel: UILabel!
	@IBOutlet weak var websiteLinkButton: UIButton!
	@IBOutlet weak var buttonHeightConstant: NSLayoutConstraint!
	
	@IBAction func dismiss() {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func urlButtonPressed(_ sender: UIButton) {
		if let url = openURL, UIApplication.shared.canOpenURL(url){
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
	@IBAction func handleButtonPressed(_ sender: UIButton) {
		let url = URL(string: "https://twitter.com/\(handle!)")!
		if UIApplication.shared.canOpenURL(url){
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		initStyle()
    }
	
	let statusStyle = NSMutableParagraphStyle()
	let textColor = UIColor(red: 41/255, green: 47/255, blue: 51/255, alpha: 1.0)
	let profilePlaceholderImage = UIImage(named : "ghost_blue")
	let bannerPlaceholderImage = UIImage(named : "GradientBackground")
	
	var openURL: URL?
	var handle: String? {
		didSet {
			getDataWithHandle(handle!)
		}
	}
	
	private func initStyle() {
		cardView.layer.cornerRadius = 8.0
		cardView.layer.masksToBounds = true
		profileImageView.layer.cornerRadius = profileImageView.frame.width/2
		profileImageView.layer.borderWidth = 2.0
		profileImageView.layer.borderColor = UIColor.white.cgColor
		profileImageView.layer.masksToBounds = true
		statusStyle.alignment = .center
		statusStyle.lineSpacing = 5.0
	}
	
	func getDataWithHandle(_ handle: String){
		TwitterAPIOperations.getAccountInfoForTwitterUser(handle, callback: { (json, error) -> Void in
			guard let json = json else {
				print(error as Any)
				return
			}
			Async.main {
				
				let description = NSAttributedString(
					 string: json["description"].stringValue,
					 attributes: [NSForegroundColorAttributeName: self.textColor,
				     NSFontAttributeName: UIFont.systemFont(ofSize: 14),
				     NSParagraphStyleAttributeName: self.statusStyle])
				self.statusLabel.attributedText = description
				self.handleButton.setTitle("@\(json["screen_name"].stringValue)", for: .normal)
				self.nameLabel.text = json["name"].stringValue
				self.locationLabel.text = json["location"].stringValue
				
				self.followersCountLabel.text = json["followers_count"].stringValue
				self.followingCountLabel.text = json["friends_count"].stringValue
				self.openURL = URL(string: json["entities"]["url"]["urls"][0]["expanded_url"].stringValue)
				self.websiteLinkButton.setTitle(
					json["entities"]["url"]["urls"][0]["display_url"].stringValue,
					for: UIControlState.normal)
				if (self.websiteLinkButton.title(for: .normal) ?? "").isEmpty {
					self.buttonHeightConstant.constant = 0
				} else {
					self.buttonHeightConstant.constant = 20
				}
				
				if	let urlString = json["profile_banner_url"].string,
					let url = URL(string: urlString + DEFAULT_BANNER_RESOLUTION){
					self.bannerImageView.kf.setImage(
						with: url, placeholder: self.bannerPlaceholderImage,
						options: [.transition(ImageTransition.fade(0.3))],
						progressBlock: nil,
						completionHandler: nil)
				}
				if let urlString = json["profile_image_url"].string, let url = URL(string: urlString){
					self.profileImageView.kf.setImage(
						with: url, placeholder: self.profilePlaceholderImage,
						options:  [.transition(ImageTransition.fade(0.3))],
						progressBlock: nil,
						completionHandler: nil)
				}
				
				UIView.animate(withDuration: 0.3, animations: {
					self.view.layoutSubviews()
				})
			}
		})
	}
}
