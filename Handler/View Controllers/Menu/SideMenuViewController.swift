//
//  SideMenuViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import HandleriOSSDK
import Kingfisher
import Async

class SideMenuViewController: UIViewController, UITableViewDelegate {

	@IBOutlet weak var profileImageView: WhiteBorderImageView!
	@IBOutlet weak var profileNameLabel: UILabel!
	@IBOutlet weak var profileHandleLabel: UILabel!
	@IBOutlet weak var profileBannerImageView: UIImageView!
	@IBOutlet weak var logoutButton: UIButton!
	@IBOutlet weak var helpButton: UIButton!
	@IBOutlet weak var gradientView: GradientView!

	var optionsTableViewController: MailBoxOptionsTableViewController? {
		didSet {
			optionsTableViewController?.tableView.delegate = self
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SideMenuViewController.updateCurrentUser), name: HRCurrentUserDidSetNotification, object: nil)

		updateCurrentUser()
		gradientView.colors = [UIColor.whiteColor(), UIColor.blackColor().colorWithAlphaComponent(0.5)]
		view.sendSubviewToBack(gradientView)
		view.sendSubviewToBack(profileBannerImageView) //Workaround
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}

	func updateCurrentUser(){
		Async.main { () -> Void in
			if let user = HRUserSessionManager.sharedManager.currentUser {
				self.profileHandleLabel.text = user.handle
				self.profileNameLabel.text = user.name
				if let url = NSURL(string: user.picture_url) {
					self.profileImageView.kf_setImageWithURL(url, placeholderImage: UIImage.randomGhostImage())
				}
				TwitterAPIOperations.getAccountInfoForTwitterUser(user.handle, callback: { (json, error) -> Void in
					guard let json = json else {
						print(error)
						return
					}
					Async.main {
						if let urlString = json["profile_banner_url"].string, let url = NSURL(string: urlString + DEFAULT_BANNER_RESOLUTION){
							self.profileBannerImageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(0.3))])
						}
					}
				})
			}
		}
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		AppDelegate.sharedInstance().sideMenu.hideMenuViewController()

		if let nc = AppDelegate.sharedInstance().sideMenu.contentViewController as? UINavigationController {

			switch indexPath.row {
			case 0:
				//Inbox
				let inboxViewController = Storyboards.Main.instantiateViewControllerWithIdentifier("InboxTableViewController")
				nc.setViewControllers([inboxViewController], animated: false)
				return
			case 1:
				// Unread
				let unreadVC = Storyboards.Main.instantiateViewControllerWithIdentifier("UnreadMailboxViewController")
				nc.setViewControllers([unreadVC], animated: false)
				break;
			case 2:
				// Flagged
				let flaggedVC = Storyboards.Main.instantiateViewControllerWithIdentifier("FlaggedMailboxViewController")
				nc.setViewControllers([flaggedVC], animated: false)
				break;
			case 3:
				// Drafts
				let draftsVC = Storyboards.Main.instantiateViewControllerWithIdentifier("DraftsMailboxViewController")
				nc.setViewControllers([draftsVC], animated: false)
				break;
			case 4:
				// Sent
				let sentVC = Storyboards.Main.instantiateViewControllerWithIdentifier("SentMailboxViewController")
				nc.setViewControllers([sentVC], animated: false)
				break;
			case 5:
				// Archive
				let archiveVC = Storyboards.Main.instantiateViewControllerWithIdentifier("ArchiveMailboxViewController")
				nc.setViewControllers([archiveVC], animated: false)
				break;
			default:
				// Error
				break;
			}
		}

	}

	@IBAction func signoutPressed(sender: UIButton) {

		let alert = UIAlertController(title: "Sign Out", message: "Are you sure? Signing out will remove all Handler data from your phone", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
			self.signOut()
		}))

		alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
		}))

		presentViewController(alert, animated: true, completion: nil)
	}

	@IBAction func helpPressed(sender: UIButton) {
		let messageNC = Storyboards.Compose.instantiateViewControllerWithIdentifier("MessageComposeNavigationController") as! GradientNavigationController
		let messageWrapper = messageNC.viewControllers.first as! MessageComposerWrapperViewController
		messageWrapper.title = "New Message"


//		let message = Message(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
//		message.recipients = NSSet(array: [User.fromHandle("handlerHQ")])
//		message.subject = "Help & feedback"
//
//		messageWrapper.draftMessage = message
//
//		self.presentViewController(messageNC, animated: true, completion: nil)
	}

	func signOut() {
		self.profileHandleLabel.text = ""
		self.profileNameLabel.text = ""
		self.profileImageView.image = UIImage.randomGhostImage()

		Async.main {
			AuthUtility.signOut()
			UIView.transitionWithView(AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
				AppDelegate.sharedInstance().window?.rootViewController = Storyboards.Intro.instantiateViewControllerWithIdentifier("LoginViewController")
				}, completion: { (success) in
					AppDelegate.sharedInstance().sideMenu.hideMenuViewController()
					let inboxViewController = Storyboards.Main.instantiateViewControllerWithIdentifier("InboxTableViewController") as! InboxTableViewController
					if let nc = AppDelegate.sharedInstance().sideMenu.contentViewController as? UINavigationController {
						nc.setViewControllers([inboxViewController], animated: true)
					}
			})
		}
	}

	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "embedMailBoxOptions" {
			self.optionsTableViewController = segue.destinationViewController as? MailBoxOptionsTableViewController
		}
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
