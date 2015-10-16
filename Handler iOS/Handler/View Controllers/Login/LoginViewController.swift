//
//  LoginViewController.swift
//  Handler
//
//  Created by Christian Praiss on 19/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import TwitterKit
import KeychainAccess
import HandlerSDK

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		let loginButton = TWTRLogInButton { (session, error) -> Void in
			if let error = error {
				print(error)
				return
			}
			let twitter = Twitter.sharedInstance()
			let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:session)
			HRTwitterAuthManager.startAuth(oauthSigning.OAuthEchoHeadersToVerifyCredentials(), callback: { (error) -> Void in
				if let error = error {
					var errorPopup = ErrorPopupViewController()
					errorPopup.error = error
					errorPopup.show()
					return
				}
				
				UIView.transitionWithView(AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
					AppDelegate.sharedInstance().window?.rootViewController = AppDelegate.sharedInstance().sideMenu
				}, completion: nil)
			})
			
		}
		
		loginButton.center = self.view.center
		self.view.addSubview(loginButton)
        // Do any additional setup after loading the view.
    }
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

}
