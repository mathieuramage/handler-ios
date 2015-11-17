//
//  SideMenuViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK
import Kingfisher
import Async

class SideMenuViewController: UIViewController, UITableViewDelegate {
	
	@IBOutlet weak var profileImageView: WhiteBorderImageView!
	@IBOutlet weak var profileNameLabel: UILabel!
	@IBOutlet weak var profileHandleLabel: UILabel!
    @IBOutlet weak var profileBannerImageView: UIImageView!
	
	
	var optionsTableViewController: MailBoxOptionsTableViewController? {
		didSet {
			optionsTableViewController?.tableView.delegate = self
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentUser", name: HRCurrentUserDidSetNotification, object: nil)
		
		updateCurrentUser()
        // Do any additional setup after loading the view.
    }
	
	func updateCurrentUser(){
		Async.main { () -> Void in
			if let user = HRUserSessionManager.sharedManager.currentUser {
				self.profileHandleLabel.text = user.handle
				self.profileNameLabel.text = user.name
				if let url = NSURL(string: user.picture_url) {
					self.profileImageView.kf_setImageWithURL(url, placeholderImage: UIImage.randomGhostImage())
				}
                TwitterAPICommunicator.getAccountInfoForTwitterUser(user.handle, callback: { (json, error) -> Void in
                    guard let json = json else {
                        print(error)
                        return
                    }
                    Async.main {
                        if let urlString = json["profile_banner_url"].string, let url = NSURL(string: urlString){
                            self.profileBannerImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "twitter_default"), optionsInfo: [.Transition(ImageTransition.Fade(0.3))])
                        }
                        
                    }
                })

			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		AppDelegate.sharedInstance().sideMenu.hideMenuViewController()
		let genericMailVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("GenericMailboxTableViewController") as! GenericMailboxTableViewController
		switch indexPath.row {
		case 0:
			//Inbox
			let inboxViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InboxTableViewController") as! InboxTableViewController
			if let nc = AppDelegate.sharedInstance().sideMenu.contentViewController as? UINavigationController {
				nc.setViewControllers([inboxViewController], animated: true)
			}
			return
		case 1:
			// Unread
			genericMailVc.mailboxType = .Unread
			break;
		case 2:
			// Flagged
			genericMailVc.mailboxType = .Flagged
			break;
		case 3:
			// Drafts
			genericMailVc.mailboxType = .Drafts
			break;
		case 4:
			// Sent
			genericMailVc.mailboxType = .Sent
			break;
		case 5:
			// Archive
			genericMailVc.mailboxType = .Archive
			break;
		default:
			// Error
			break;
		}
		
		if indexPath.row != 0, let nc = AppDelegate.sharedInstance().sideMenu.contentViewController as? UINavigationController {
			nc.setViewControllers([genericMailVc], animated: true)
		}
	}

	@IBAction func signoutPressed(sender: UIButton) {
		APICommunicator.sharedInstance.signOut()
		UIView.transitionWithView(AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
			AppDelegate.sharedInstance().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
			}, completion: nil)
	}
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "embedMailBoxOptions" {
			self.optionsTableViewController = segue.destinationViewController as? MailBoxOptionsTableViewController
		}
    }
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
