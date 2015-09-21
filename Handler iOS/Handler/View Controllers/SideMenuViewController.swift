//
//  SideMenuViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK
import WebImage

class SideMenuViewController: UIViewController, UITableViewDelegate {
	
	@IBOutlet weak var profileImageView: WhiteBorderImageView!
	@IBOutlet weak var profileNameLabel: UILabel!
	@IBOutlet weak var profileHandleLabel: UILabel!
	
	
	var optionsTableViewController: UITableViewController? {
		didSet {
			optionsTableViewController?.tableView.delegate = self
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentUser", name: HRCurrentUserDidSetNotification, object: nil)
        // Do any additional setup after loading the view.
    }
	
	func updateCurrentUser(){
		if let user = HRUserSessionManager.sharedManager.currentUser {
			self.profileHandleLabel.text = user.handle
			self.profileNameLabel.text = user.name
			if let url = NSURL(string: user.picture_url) {
				self.profileImageView.sd_setImageWithURL(url)
			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print(indexPath)
		AppDelegate.sharedInstance().sideMenu?.hideMenuViewController()
	}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "embedMailBoxOptions" {
			self.optionsTableViewController = segue.destinationViewController as? UITableViewController
		}
    }
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
