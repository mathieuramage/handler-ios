//
//  SendInvitationViewController.swift
//  Handler
//
//  Created by Christian Praiss on 30/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
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
				byTweetButton.backgroundColor = UIColor(rgba: HexCodes.lightBlue)
				if MFMessageComposeViewController.canSendText() {
					bySmsButton.isEnabled = true
					bySmsButton.backgroundColor = UIColor(rgba: HexCodes.green)
				} else {
					bySmsButton.isEnabled = false
					bySmsButton.backgroundColor = UIColor.lightGray
				}
				byTweetButton.isEnabled  = true
			} else {
				bySmsButton.backgroundColor = UIColor.lightGray
				byTweetButton.backgroundColor = UIColor.lightGray
				bySmsButton.isEnabled = false
				byTweetButton.isEnabled  = false
			}
		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		UINib(nibName: "SendInvitationViewController", bundle: Bundle.main).instantiate(withOwner: self, options: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@IBAction func dismiss() {
		UIView.animate(withDuration: 0.3, animations: { () -> Void in
			self.window?.alpha = 0
			UIApplication.shared.statusBarStyle = .lightContent
			}, completion: { (success) -> Void in
				self.window = nil
		}) 
	}
	
	@IBAction func inviteBySMS(_ sender: UIButton) {
		let composer = MFMessageComposeViewController()
		composer.delegate = self
		composer.body = "Hey \(twitterHandle)! check out Handler, a new email app for Twitter. http://handlerapp.com/get"
		present(composer, animated: true, completion: nil)
	}
    
    func dismissPressed(_ sender: AnyObject?) {
        dismiss()
    }
	
	@IBAction func inviteByTweet(_ sender: UIButton) {
		let composer = TWTRComposer()
		composer.setImage(nil)
		composer.setText("Hey @\(twitterHandle)! check out Handler, a new email app for Twitter.")
		composer.setURL(URL(string:"www.handlerapp.com/get")!)
		composer.show(from: self) { (result) -> Void in
			switch result {
			case .done:
				self.dismiss()
				return
			case .cancelled:
				return
			}
		}
	}
	
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		if result == MessageComposeResult.cancelled {
			return
		}else if (result == MessageComposeResult.failed || result == MessageComposeResult.sent){
			dismiss()
		}
	}
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
