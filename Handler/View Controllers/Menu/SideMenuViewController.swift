//
//  SideMenuViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Intercom
import UIKit
import Kingfisher
import Async
import GradientView
import SwiftyJSON

class SideMenuViewController: UIViewController, UITableViewDelegate {
	
	@IBOutlet weak var profileImageView: WhiteBorderImageView!
	@IBOutlet weak var profileNameLabel: UILabel!
	@IBOutlet weak var profileHandleLabel: UILabel!
	@IBOutlet weak var profileBannerImageView: UIImageView!
	@IBOutlet weak var logoutButton: UIButton!
	@IBOutlet weak var helpButton: UIButton!
	@IBOutlet weak var gradientView: GradientView!
	@IBOutlet weak var separatorView: UIView!
	
	var optionsTableViewController: MailBoxOptionsTableViewController? {
		didSet {
			optionsTableViewController?.tableView.delegate = self
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//		TODO ? NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SideMenuViewController.updateCurrentUser), name: HRCurrentUserDidSetNotification, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		if (profileHandleLabel.text ?? "").isEmpty {
			updateCurrentUser()
			updateUI()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	private func updateUI() {
		view.sendSubview(toBack: gradientView)
		view.sendSubview(toBack: profileBannerImageView) //Workaround
		remoteConfigDisplayHelpButton()
		profileImageView.layer.cornerRadius = profileImageView.frame.width/2
		profileImageView.layer.masksToBounds = true
		profileImageView.layer.borderWidth = 1.5
		profileImageView.layer.borderColor = UIColor.white.cgColor
	}
	
	func updateCurrentUser() {
		guard let handle = UserDefaults.standard.string(forKey: Config.UserDefaults.uidKey) else {
			return
		}

		func handleUserResponse(json: JSON){
			Async.main {
				self.profileHandleLabel.text = "@\(json["screen_name"].stringValue)"
				self.profileNameLabel.text = "\(json["name"].stringValue)"
				if let urlString = json["profile_banner_url"].string, let url = URL(string: urlString + DEFAULT_BANNER_RESOLUTION){
					self.profileBannerImageView.kf.setImage(with: url, placeholder: UIImage.randomGhostImage(), options: [.transition(ImageTransition.fade(0.3))], progressBlock: nil, completionHandler: nil)
				}
				if let urlString = json["profile_image_url"].string {
					let regularImg = urlString.replacingOccurrences(of: "_normal", with: "", options: .literal, range: nil)
					let url = URL(string: regularImg)
					self.profileImageView.kf.setImage(with: url, placeholder: UIImage.randomGhostImage(), options:  [.transition(ImageTransition.fade(0.3))], progressBlock: nil, completionHandler: nil)
				}
				UIView.animate(withDuration: 0.3, animations: {
					self.view.layoutSubviews()
				})
			}
		}

		TwitterAPIOperations.getAccountInfoForTwitterUser(handle, callback: { (json, error) -> Void in
			guard let userJson = json else {
				print(error as Any)
				return
			}
			handleUserResponse(json: userJson)
		})
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		AppDelegate.sharedInstance().sideMenu.hideMenuViewController()
		
		if let nc = AppDelegate.sharedInstance().sideMenu.contentViewController as? UINavigationController {
			
			switch indexPath.row {
			case 0:
				//Inbox
				let inboxViewController = Storyboards.Main.instantiateViewController(withIdentifier: "InboxTableViewController")
				nc.setViewControllers([inboxViewController], animated: false)
				return
			case 1:
				// Unread
				let unreadVC = Storyboards.Main.instantiateViewController(withIdentifier: "UnreadMailboxViewController")
				nc.setViewControllers([unreadVC], animated: false)
				break;
			case 2:
				// Flagged
				let flaggedVC = Storyboards.Main.instantiateViewController(withIdentifier: "FlaggedMailboxViewController")
				nc.setViewControllers([flaggedVC], animated: false)
				break;
			case 3:
				// Drafts
				let draftsVC = Storyboards.Main.instantiateViewController(withIdentifier: "DraftsMailboxViewController")
				nc.setViewControllers([draftsVC], animated: false)
				break;
			case 4:
				// Sent
				let sentVC = Storyboards.Main.instantiateViewController(withIdentifier: "SentMailboxViewController")
				nc.setViewControllers([sentVC], animated: false)
				break;
			case 5:
				// Archive
				let archiveVC = Storyboards.Main.instantiateViewController(withIdentifier: "ArchiveMailboxViewController")
				nc.setViewControllers([archiveVC], animated: false)
				break;
			default:
				// Error
				break;
			}
		}
		
	}
	
	@IBAction func signoutPressed(_ sender: UIButton) {
		
		let alert = UIAlertController(title: "Sign Out", message: "Are you sure? Signing out will remove all Handler data from your phone", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
			self.signOut()
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
		}))
		
		present(alert, animated: true, completion: nil)
	}

	@IBAction func helpPressed(_ sender: UIButton) {
		Intercom.presentMessenger()
		
		//		let message = Message(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
		//		message.recipients = NSSet(array: [User.fromHandle("handlerHQ")])
		//		message.subject = "Help & feedback"
		//
		//		messageWrapper.draftMessage = message
		//
		//		self.presentViewController(messageNC, animated: true, completion: nil)
		
		AppAnalytics.fireContentViewEvent(contentId: AppEvents.SideMenu.feedback, event: AppEvents.SideMenu.self)
	}
	
	func signOut() {
		profileHandleLabel.text = ""
		profileNameLabel.text = ""
		profileImageView.image = UIImage.randomGhostImage()
		
		Async.main {
			AuthUtility.signOut()
			UIView.transition(with: AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
				AppDelegate.sharedInstance().window?.rootViewController = Storyboards.Intro.instantiateViewController(withIdentifier: "LoginViewController")
			}, completion: { (success) in
				AppDelegate.sharedInstance().sideMenu.hideMenuViewController()
				let inboxViewController = Storyboards.Main.instantiateViewController(withIdentifier: "InboxTableViewController") as! InboxTableViewController
				if let nc = AppDelegate.sharedInstance().sideMenu.contentViewController as? UINavigationController {
					nc.setViewControllers([inboxViewController], animated: true)
				}
				AppAnalytics.fireContentViewEvent(contentId: AppEvents.SideMenu.logout, event: AppEvents.SideMenu.self)
			})
		}
	}
	
	private func remoteConfigDisplayHelpButton() {
		let hideFeedbackButton = !Config.Firebase.RemoteConfig.instance.configValue(forKey: Config.Firebase.ParamKeys.showSupportMenu).boolValue
		helpButton.isHidden = hideFeedbackButton
		separatorView.isHidden = hideFeedbackButton
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "embedMailBoxOptions" {
			optionsTableViewController = segue.destination as? MailBoxOptionsTableViewController
		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
}
