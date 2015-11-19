//
//  SendInvitationViewController.swift
//  Handler
//
//  Created by Christian Praiss on 30/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import TwitterKit
import MessageUI

class SendInvitationViewController: UIViewController, UIViewControllerShow, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
	
	var window: UIWindow?

	@IBOutlet weak var inviteTitleLabel: UILabel!
	@IBOutlet weak var catchySentenceLabel: UILabel!
	@IBOutlet weak var profileImageView: WhiteBorderImageView!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var bySmsButton: UIButton!
	@IBOutlet weak var byTweetButton: UIButton!
	
	var twitterHandle: String? {
		didSet {
			if let _ = twitterHandle {
				byTweetButton.backgroundColor = UIColor.hrTwitterBlueColor()
				if MFMessageComposeViewController.canSendText() {
					bySmsButton.enabled = true
					bySmsButton.backgroundColor = UIColor.hrGreenColor()
				}else{
					bySmsButton.enabled = false
					bySmsButton.backgroundColor = UIColor.lightGrayColor()
				}
				byTweetButton.enabled  = true
			}else{
				bySmsButton.backgroundColor = UIColor.lightGrayColor()
				byTweetButton.backgroundColor = UIColor.lightGrayColor()
				bySmsButton.enabled = false
				byTweetButton.enabled  = false
			}
		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		UINib(nibName: "SendInvitationViewController", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@IBAction func dismiss(){
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.window?.alpha = 0
			UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
			}) { (success) -> Void in
				self.window = nil
		}
	}
	
	@IBAction func inviteBySMS(sender: UIButton) {
		let composer = MFMessageComposeViewController()
		composer.delegate = self
		composer.body = "Hey \(twitterHandle)! check out Handler, a new email app for Twitter. http://handlerapp.com/get"
		presentViewController(composer, animated: true, completion: nil)
	}
    
    func dismissPressed(sender: AnyObject?) {
        dismiss()
    }
	
	@IBAction func inviteByTweet(sender: UIButton) {
		let composer = TWTRComposer()
		composer.setImage(nil)
		composer.setText("Hey @\(twitterHandle)! check out Handler, a new email app for Twitter.")
		composer.setURL(NSURL(string:"www.handlerapp.com/get")!)
		composer.showFromViewController(self) { (result) -> Void in
			switch result {
			case .Done:
				self.dismiss()
				return
			case .Cancelled:
				return
			}
		}
	}
	
	func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
		if result == MessageComposeResultCancelled {
			return
		}else if (result == MessageComposeResultFailed || result == MessageComposeResultSent){
			dismiss()
		}
	}
}
